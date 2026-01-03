"""Commands handlers - /v1/devices/{deviceId}/commands"""
from datetime import datetime, timezone
import logging

from storage import devices_store, commands_store, generate_id

logger = logging.getLogger("plant_nanny.commands")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


def post(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Create a command for a device (force reading, pump, etc.)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")

    logger.info(f"Create command request - device={device_id} user_uid={user_uid}")

    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        logger.info(f"Device lookup failed. device_exists={bool(device)} ownerUid={device.get('ownerUid') if device else None} user_uid={user_uid}")
        return {"error": "Device not found"}, 404

    now = datetime.now(timezone.utc).isoformat()
    command_id = generate_id()
    
    command = {
        "id": command_id,
        "deviceId": device_id,
        "type": body["type"],
        "status": "pending",
        "createdAt": now,
        "updatedAt": now,
        "durationMs": body.get("durationMs"),
        "amountMl": body.get("amountMl"),
        "requestedBy": user_uid,
        "errorMessage": None,
    }
    
    if device_id not in commands_store:
        commands_store[device_id] = []
    commands_store[device_id].append(command)
    
    return command, 201


def get(device_id: str, limit: int = 100, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """List commands (for UI history/debug)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    device_commands = commands_store.get(device_id, [])
    sorted_commands = sorted(device_commands, key=lambda c: c["createdAt"], reverse=True)
    limited = sorted_commands[:limit]
    
    return {
        "count": len(limited),
        "items": limited,
    }, 200


def pending_get(device_id: str, max: int = 5, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """ESP32 polls pending commands."""
    device_info = token_info or user or {}
    auth_device_id = device_info.get("device_id")
    
    if auth_device_id != device_id:
        return {"error": "Device key doesn't match device ID"}, 401
    
    device_commands = commands_store.get(device_id, [])
    pending = [c for c in device_commands if c["status"] == "pending"]
    sorted_pending = sorted(pending, key=lambda c: c["createdAt"])
    limited = sorted_pending[:max]
    
    now = datetime.now(timezone.utc).isoformat()
    for cmd in limited:
        cmd["status"] = "sent"
        cmd["updatedAt"] = now
    
    return {
        "count": len(limited),
        "items": limited,
    }, 200


def command_id_ack_post(
    device_id: str, 
    command_id: str, 
    body: dict,
    user: dict = None,
    token_info: dict = None,
) -> tuple[dict, int]:
    """ESP32 acknowledges command execution result."""
    device_info = token_info or user or {}
    auth_device_id = device_info.get("device_id")
    
    if auth_device_id != device_id:
        return {"error": "Device key doesn't match device ID"}, 401
    
    device_commands = commands_store.get(device_id, [])
    
    command = None
    for cmd in device_commands:
        if cmd["id"] == command_id:
            command = cmd
            break
    
    if not command:
        return {"error": "Command not found"}, 404
    
    now = datetime.now(timezone.utc).isoformat()
    command["status"] = body["status"]
    command["updatedAt"] = now
    if body.get("errorMessage"):
        command["errorMessage"] = body["errorMessage"]
    
    return command, 200
