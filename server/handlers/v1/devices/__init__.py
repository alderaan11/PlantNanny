"""Device handlers - /v1/devices"""
from datetime import datetime, timezone, timedelta
import asyncio
import logging

import database as db

logger = logging.getLogger("plant_nanny.devices")


async def get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """List devices for current user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    devices = await db.get_devices_by_owner(user_uid)
    
    return {
        "count": len(devices),
        "items": [d.to_dict() for d in devices],
    }, 200


async def _force_reading_async(device_id: str):
    """Send force reading command to device via MQTT."""
    try:
        from mqtt_handler import force_device_reading
        success = await force_device_reading(device_id)
        if success:
            logger.info(f"Force reading command sent to {device_id}")
        else:
            logger.warning(f"Failed to send force reading command to {device_id}")
    except Exception as e:
        logger.error(f"Error sending force reading command to {device_id}: {e}")


async def register_post(body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Register (pair) a device to the authenticated user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    pairing_code = body.get("pairingCode")
    name = body.get("name", f"Device {pairing_code}")
    
    # Device ID is the pairing code directly (UUID format from ESP32)
    device_id = pairing_code
    
    # Check if device already exists in DB (may have been auto-created by MQTT)
    existing_device = await db.get_device(device_id)
    
    if existing_device:
        # Device exists - check ownership
        if existing_device.owner_uid and existing_device.owner_uid != user_uid and existing_device.owner_uid != "unassigned":
            return {"error": "Device already registered to another user"}, 409
        
        # Claim device for this user if unassigned
        if existing_device.owner_uid == "unassigned":
            await db.update_device(device_id, owner_uid=user_uid, name=name)
            logger.info(f"Claimed existing device {device_id} for user {user_uid}")
            existing_device = await db.get_device(device_id)
        
        return existing_device.to_dict(), 200
    
    # Device not found - create it in the database
    try:
        device = await db.create_device(
            device_id=device_id,
            name=name,
            owner_uid=user_uid,
            firmware_version="1.0.0-dev",
        )
        logger.info(f"Created new device {device_id} for user {user_uid}")
        
        # Send force reading command to device via MQTT
        try:
            asyncio.create_task(_force_reading_async(device_id))
        except Exception as e:
            logger.warning(f"Could not send force reading command during registration: {e}")
        
        return device.to_dict(), 200
        
    except Exception as e:
        logger.error(f"Failed to create device {device_id}: {e}")
        return {"error": "Failed to register device"}, 500


async def device_id_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get device details."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    return device.to_dict(), 200


async def device_id_patch(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Update device (rename, metadata)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    if "name" in body:
        await db.update_device(device_id, name=body["name"])
        device = await db.get_device(device_id)
    
    return device.to_dict(), 200


async def device_id_unregister_post(device_id: str, user: dict = None, token_info: dict = None) -> tuple[str, int]:
    """Unregister device from current user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    # Set owner to unassigned instead of deleting
    await db.update_device(device_id, owner_uid="unassigned")
    
    return "", 204


async def device_id_status_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get device status (connectivity, lastSeen, firmware)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    online = False
    if device.last_seen:
        now = datetime.now(timezone.utc)
        online = (now - device.last_seen).total_seconds() < 60
    
    return {
        "deviceId": device_id,
        "online": online,
        "lastSeen": device.last_seen.isoformat() if device.last_seen else None,
        "firmwareVersion": device.firmware_version,
        "lastStatus": device.last_status,
    }, 200
