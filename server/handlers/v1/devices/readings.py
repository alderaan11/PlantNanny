"""Readings handlers - /v1/devices/{deviceId}/readings"""
from datetime import datetime, timezone
from typing import Optional

import database as db


async def post(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Ingest a sensor reading (ESP32)."""
    device_info = token_info or user or {}
    auth_device_id = device_info.get("device_id")
    
    if auth_device_id != device_id:
        return {"error": "Device key doesn't match device ID"}, 401
    
    # Update device last_seen is done automatically in create_reading
    ts_str = body.get("ts")
    ts = None
    if ts_str:
        try:
            ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        except ValueError:
            ts = datetime.now(timezone.utc)
    
    reading = await db.create_reading(
        device_id=device_id,
        temperature_c=body.get("temperatureC"),
        humidity_pct=body.get("humidityPct"),
        luminosity_pct=body.get("luminosityPct"),
        soil_moisture_pct=body.get("soilMoisturePct"),
        ts=ts,
    )
    
    return reading.to_dict(), 201


async def get(
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
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    from_dt = None
    to_dt = None
    
    if from_:
        try:
            from_dt = datetime.fromisoformat(from_.replace("Z", "+00:00"))
        except ValueError:
            pass
    
    if to:
        try:
            to_dt = datetime.fromisoformat(to.replace("Z", "+00:00"))
        except ValueError:
            pass
    
    readings = await db.get_readings(
        device_id=device_id,
        from_dt=from_dt,
        to_dt=to_dt,
        limit=limit,
        order=order,
    )
    
    return {
        "count": len(readings),
        "items": [r.to_dict() for r in readings],
    }, 200


async def last_get(device_id: str, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Get last reading."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    reading = await db.get_last_reading(device_id)
    if not reading:
        return {"error": "No readings available"}, 404
    
    return reading.to_dict(), 200


async def aggregate_get(
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
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    try:
        from_dt = datetime.fromisoformat(from_.replace("Z", "+00:00"))
        to_dt = datetime.fromisoformat(to.replace("Z", "+00:00"))
    except ValueError:
        return {"error": "Invalid date format"}, 400
    
    # For now, return simple aggregates
    # TODO: Implement proper bucketed aggregation in database layer
    stats = await db.get_readings_aggregated(device_id, from_dt, to_dt)
    
    return {
        "bucket": bucket,
        "from": from_,
        "to": to,
        "stats": stats,
        "items": [],  # TODO: Implement time-bucketed data
    }, 200
