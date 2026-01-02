"""OTA handlers - /v1/devices/{deviceId}/ota"""
from datetime import datetime, timezone

from storage import devices_store, commands_store, generate_id


def post(device_id: str, body: dict = None, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Request OTA check/update."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    body = body or {}
    now = datetime.now(timezone.utc).isoformat()
    command_id = generate_id()
    
    cmd_type = "ota_update" if body.get("version") else "ota_check"
    
    command = {
        "id": command_id,
        "deviceId": device_id,
        "type": cmd_type,
        "status": "pending",
        "createdAt": now,
        "updatedAt": now,
        "durationMs": None,
        "amountMl": None,
        "requestedBy": user_uid,
        "errorMessage": None,
    }
    
    if device_id not in commands_store:
        commands_store[device_id] = []
    commands_store[device_id].append(command)
    
    return command, 201
