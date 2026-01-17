"""Firmware handlers - /v1/firmware"""
from datetime import datetime, timezone
import hashlib
import logging
import os
from pathlib import Path

import database as db

logger = logging.getLogger("plant_nanny.firmware")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Firmware storage directory
FIRMWARE_DIR = Path(__file__).parent.parent.parent / "firmware_files"
FIRMWARE_DIR.mkdir(exist_ok=True)


async def latest_get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get the latest firmware version info."""
    firmware = await db.get_latest_firmware()
    if not firmware:
        return {"error": "No firmware available"}, 404
    
    return firmware.to_dict(), 200


async def get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """List all firmware versions."""
    firmware_list = await db.get_all_firmware()
    
    return {
        "count": len(firmware_list),
        "items": [f.to_dict() for f in firmware_list],
    }, 200


async def post(body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Upload new firmware metadata."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    # TODO: Add admin role check
    logger.info(f"Firmware upload request by user={user_uid}")
    
    version = body["version"]
    
    # Check if version already exists
    existing = await db.get_firmware(version)
    if existing:
        return {"error": f"Firmware version {version} already exists"}, 409
    
    firmware = await db.set_firmware(
        version=version,
        url=body["url"],
        filename=body.get("filename", f"firmware_{version}.bin"),
        size=body.get("size", 0),
        checksum=body.get("checksum", ""),
        is_latest=body.get("isLatest", True),
        release_notes=body.get("releaseNotes"),
    )
    
    return firmware.to_dict(), 201


async def version_get(version: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get specific firmware version info."""
    firmware = await db.get_firmware(version)
    if not firmware:
        return {"error": f"Firmware version {version} not found"}, 404
    
    return firmware.to_dict(), 200


async def upload_post(body: bytes, user: dict = None, token_info: dict = None, **kwargs) -> tuple[dict, int]:
    """Upload firmware binary file."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    logger.info(f"Firmware binary upload by user={user_uid}, size={len(body)} bytes")
    
    # Calculate checksum
    checksum = hashlib.sha256(body).hexdigest()
    
    # Generate version from timestamp if not provided
    version = kwargs.get("version", datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S"))
    filename = f"firmware_{version}.bin"
    filepath = FIRMWARE_DIR / filename
    
    # Save file
    with open(filepath, "wb") as f:
        f.write(body)
    
    # Create/update firmware record
    url = f"/v1/firmware/{version}/download"
    
    firmware = await db.set_firmware(
        version=version,
        url=url,
        filename=filename,
        size=len(body),
        checksum=checksum,
        is_latest=True,
        release_notes=None,
    )
    
    logger.info(f"Firmware {version} saved: {filepath}")
    
    return firmware.to_dict(), 201


async def version_download_get(version: str, user: dict = None, token_info: dict = None) -> tuple:
    """Download firmware binary."""
    firmware = await db.get_firmware(version)
    if not firmware:
        return {"error": f"Firmware version {version} not found"}, 404
    
    filepath = FIRMWARE_DIR / firmware.filename
    if not filepath.exists():
        return {"error": "Firmware file not found on server"}, 404
    
    with open(filepath, "rb") as f:
        content = f.read()
    
    # Return binary with appropriate headers
    return content, 200, {
        "Content-Type": "application/octet-stream",
        "Content-Disposition": f'attachment; filename="{firmware.filename}"',
        "Content-Length": str(len(content)),
        "X-Firmware-Version": firmware.version,
        "X-Firmware-Checksum": firmware.checksum,
    }


async def devices_get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get firmware version status for all devices."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    # Get latest firmware
    latest = await db.get_latest_firmware()
    latest_version = latest.version if latest else "unknown"
    
    # Get all devices for this user
    devices = await db.get_devices_by_owner(user_uid)
    
    up_to_date = 0
    needs_update = 0
    device_statuses = []
    
    for device in devices:
        fw_version = device.firmware_version or "unknown"
        is_current = fw_version == latest_version
        if is_current:
            up_to_date += 1
        else:
            needs_update += 1
        
        device_statuses.append({
            "deviceId": device.device_id,
            "name": device.name,
            "currentVersion": fw_version,
            "isUpToDate": is_current,
            "lastSeen": device.last_seen.isoformat() if device.last_seen else None,
        })
    
    return {
        "latestVersion": latest_version,
        "totalDevices": len(devices),
        "upToDate": up_to_date,
        "needsUpdate": needs_update,
        "devices": device_statuses,
    }, 200


async def device_ota_post(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Trigger OTA update for a specific device."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    # Check device ownership
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    # Get latest firmware
    firmware = await db.get_latest_firmware()
    if not firmware:
        return {"error": "No firmware available"}, 400
    
    # Create OTA command
    try:
        from handlers.v1.devices.commands import _publish_command_via_mqtt
        
        command = await db.create_command(
            device_id=device_id,
            command_type="ota_update",
            requested_by=user_uid,
        )
        
        # Try to publish via MQTT
        success = await _publish_command_via_mqtt(
            device_id, 
            "ota_update", 
            {"url": firmware.url}
        )
        
        if success:
            await db.update_command_status(command.id, "sent")
            return {
                "deviceId": device_id,
                "status": "sent",
                "firmwareUrl": firmware.url,
                "targetVersion": firmware.version,
            }, 200
        else:
            return {
                "deviceId": device_id,
                "status": "pending",
                "firmwareUrl": firmware.url,
                "targetVersion": firmware.version,
            }, 202
            
    except Exception as e:
        logger.error(f"Failed to trigger OTA for {device_id}: {e}")
        return {
            "deviceId": device_id,
            "status": "pending",
            "firmwareUrl": firmware.url,
            "targetVersion": firmware.version,
        }, 202
