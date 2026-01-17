"""OTA handlers - /v1/devices/{deviceId}/ota"""
from datetime import datetime, timezone

import database as db


async def post(device_id: str, body: dict = None, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Request OTA check/update."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    body = body or {}
    cmd_type = "ota_update" if body.get("version") else "ota_check"
    
    command = await db.create_command(
        device_id=device_id,
        command_type=cmd_type,
        requested_by=user_uid,
    )
    
    return command.to_dict(), 201
