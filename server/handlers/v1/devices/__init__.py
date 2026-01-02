"""Device handlers - /v1/devices"""
from datetime import datetime, timezone

from storage import devices_store, device_keys, generate_id


def get(user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """List devices for current user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    user_devices = [
        d for d in devices_store.values() 
        if d.get("ownerUid") == user_uid
    ]
    
    return {
        "count": len(user_devices),
        "items": user_devices,
    }, 200


def register_post(body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Register (pair) a device to the authenticated user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    pairing_code = body.get("pairingCode")
    name = body.get("name", f"Device {pairing_code}")
    
    # In a real implementation, validate the pairing code
    device_id = f"esp32-{pairing_code.lower().replace('-', '')}"
    
    # Check if device already exists
    if device_id in devices_store:
        existing = devices_store[device_id]
        if existing.get("ownerUid") and existing["ownerUid"] != user_uid:
            return {"error": "Pairing code already used by another user"}, 409
    
    now = datetime.now(timezone.utc).isoformat()
    device = {
        "deviceId": device_id,
        "name": name,
        "ownerUid": user_uid,
        "createdAt": now,
        "lastSeen": None,
        "firmwareVersion": None,
    }
    devices_store[device_id] = device
    
    # Create a device API key for the device
    api_key = f"device-key-{device_id}"
    device_keys[api_key] = device_id
    
    return device, 200


def device_id_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get device details."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    return device, 200


def device_id_patch(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Update device (rename, metadata)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    if "name" in body:
        device["name"] = body["name"]
    
    devices_store[device_id] = device
    return device, 200


def device_id_unregister_post(device_id: str, user: dict = None, token_info: dict = None) -> tuple[str, int]:
    """Unregister device from current user."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    device["ownerUid"] = None
    devices_store[device_id] = device
    
    return "", 204


def device_id_status_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get device status (connectivity, lastSeen, firmware)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    last_seen = device.get("lastSeen")
    online = False
    if last_seen:
        try:
            last_seen_dt = datetime.fromisoformat(last_seen.replace("Z", "+00:00"))
            now = datetime.now(timezone.utc)
            online = (now - last_seen_dt).total_seconds() < 60
        except (ValueError, TypeError):
            pass
    
    return {
        "deviceId": device_id,
        "online": online,
        "lastSeen": last_seen,
        "wifiRssi": device.get("wifiRssi"),
        "ip": device.get("ip"),
        "firmwareVersion": device.get("firmwareVersion"),
    }, 200
