"""Readings handlers - /v1/devices/{deviceId}/readings"""
from datetime import datetime, timezone
from typing import Optional

from storage import devices_store, readings_store, generate_id


def post(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Ingest a sensor reading (ESP32)."""
    device_info = token_info or user or {}
    auth_device_id = device_info.get("device_id")
    
    if auth_device_id != device_id:
        return {"error": "Device key doesn't match device ID"}, 401
    
    if device_id in devices_store:
        devices_store[device_id]["lastSeen"] = datetime.now(timezone.utc).isoformat()
    
    ts = body.get("ts") or datetime.now(timezone.utc).isoformat()
    reading_id = generate_id()
    
    reading = {
        "id": reading_id,
        "deviceId": device_id,
        "ts": ts,
        "temperatureC": body["temperatureC"],
        "humidityPct": body["humidityPct"],
        "luminosityPct": body["luminosityPct"],
    }
    
    if device_id not in readings_store:
        readings_store[device_id] = []
    readings_store[device_id].append(reading)
    
    return reading, 201


def get(
    device_id: str,
    from_: Optional[str] = None,
    to: Optional[str] = None,
    limit: int = 200,
    order: str = "desc",
    user: dict = None,
    token_info: dict = None,
) -> tuple[dict, int]:
    """Query readings history (Flutter)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    device_readings = readings_store.get(device_id, [])
    
    filtered = device_readings
    if from_:
        try:
            from_dt = datetime.fromisoformat(from_.replace("Z", "+00:00"))
            filtered = [r for r in filtered if datetime.fromisoformat(r["ts"].replace("Z", "+00:00")) >= from_dt]
        except ValueError:
            pass
    
    if to:
        try:
            to_dt = datetime.fromisoformat(to.replace("Z", "+00:00"))
            filtered = [r for r in filtered if datetime.fromisoformat(r["ts"].replace("Z", "+00:00")) < to_dt]
        except ValueError:
            pass
    
    reverse = order == "desc"
    filtered = sorted(filtered, key=lambda r: r["ts"], reverse=reverse)
    filtered = filtered[:limit]
    
    return {
        "count": len(filtered),
        "items": filtered,
    }, 200


def last_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get last reading."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    device_readings = readings_store.get(device_id, [])
    if not device_readings:
        return {"error": "No readings available"}, 404
    
    sorted_readings = sorted(device_readings, key=lambda r: r["ts"], reverse=True)
    return sorted_readings[0], 200


def aggregate_get(
    device_id: str,
    from_: str,
    to: str,
    bucket: str,
    user: dict = None,
    token_info: dict = None,
) -> tuple[dict, int]:
    """Aggregate readings for charts."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    bucket_seconds = {
        "1m": 60,
        "5m": 300,
        "15m": 900,
        "1h": 3600,
        "6h": 21600,
        "1d": 86400,
    }.get(bucket, 300)
    
    try:
        from_dt = datetime.fromisoformat(from_.replace("Z", "+00:00"))
        to_dt = datetime.fromisoformat(to.replace("Z", "+00:00"))
    except ValueError:
        return {"error": "Invalid date format"}, 400
    
    device_readings = readings_store.get(device_id, [])
    
    filtered = []
    for r in device_readings:
        try:
            r_dt = datetime.fromisoformat(r["ts"].replace("Z", "+00:00"))
            if from_dt <= r_dt < to_dt:
                filtered.append((r_dt, r))
        except ValueError:
            continue
    
    buckets_data: dict[int, list] = {}
    for r_dt, r in filtered:
        bucket_start = int(r_dt.timestamp()) // bucket_seconds * bucket_seconds
        if bucket_start not in buckets_data:
            buckets_data[bucket_start] = []
        buckets_data[bucket_start].append(r)
    
    items = []
    for bucket_start in sorted(buckets_data.keys()):
        readings_in_bucket = buckets_data[bucket_start]
        temps = [r["temperatureC"] for r in readings_in_bucket]
        humidity = [r["humidityPct"] for r in readings_in_bucket]
        luminosity = [r["luminosityPct"] for r in readings_in_bucket]
        
        items.append({
            "ts": datetime.fromtimestamp(bucket_start, tz=timezone.utc).isoformat(),
            "temperatureC_avg": sum(temps) / len(temps),
            "temperatureC_min": min(temps),
            "temperatureC_max": max(temps),
            "humidityPct_avg": sum(humidity) / len(humidity),
            "luminosityPct_avg": sum(luminosity) / len(luminosity),
        })
    
    return {
        "bucket": bucket,
        "from": from_,
        "to": to,
        "items": items,
    }, 200
