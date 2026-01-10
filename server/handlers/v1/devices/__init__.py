"""Device handlers - /v1/devices"""
from datetime import datetime, timezone, timedelta
import random

from storage import devices_store, device_keys, readings_store, generate_id


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
        # Device already belongs to this user, return it
        return existing, 200
    
    now = datetime.now(timezone.utc)
    device = {
        "deviceId": device_id,
        "name": name,
        "ownerUid": user_uid,
        "createdAt": now.isoformat(),
        "lastSeen": now.isoformat(),
        "firmwareVersion": "1.0.0-dev",
    }
    devices_store[device_id] = device
    
    # Create a device API key for the device
    api_key = f"device-key-{device_id}"
    device_keys[api_key] = device_id
    
    # Seed fake readings for development (last 24 hours)
    _seed_fake_readings_for_device(device_id, now)
    
    return device, 200


def _seed_fake_readings_for_device(device_id: str, now: datetime) -> None:
    """Generate fake readings for a newly registered device (dev mode)."""
    readings = []
    base_temp = random.uniform(18, 24)
    base_humidity = random.uniform(40, 70)
    base_luminosity = random.uniform(30, 80)
    
    for i in range(96):  # 24h * 4 readings/hour (every 15 min)
        ts = now - timedelta(minutes=15 * (95 - i))
        hour = ts.hour
        
        # Temperature varies with time of day (peak at 2 PM)
        temp_variation = 3 * (1 - abs(hour - 14) / 14)
        
        # Luminosity varies with daylight
        if 6 <= hour <= 20:
            lum_variation = 40 * (1 - abs(hour - 13) / 7)
        else:
            lum_variation = -base_luminosity * 0.8
        
        reading = {
            "id": generate_id(),
            "deviceId": device_id,
            "ts": ts.isoformat(),
            "temperatureC": round(base_temp + temp_variation + random.uniform(-1, 1), 1),
            "humidityPct": round(max(0, min(100, base_humidity + random.uniform(-5, 5))), 1),
            "luminosityPct": round(max(0, min(100, base_luminosity + lum_variation + random.uniform(-5, 5))), 1),
        }
        readings.append(reading)
    
    readings_store[device_id] = readings
    print(f"✓ Seeded {len(readings)} fake readings for {device_id}")


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
