"""Commands handlers - /v1/devices/{deviceId}/commands"""
from datetime import datetime, timezone
import logging
import asyncio

import database as db

logger = logging.getLogger("plant_nanny.commands")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


async def _publish_command_via_mqtt(device_id: str, command_type: str, command_data: dict) -> bool:
    """Publish command to device via MQTT for immediate delivery."""
    try:
        from mqtt_handler import publish_device_command
        
        action_map = {
            "force_reading": "send_now",
            "pump_water": "pump_water",
            "set_interval": "set_interval",
            "restart": "restart",
            "ota_update": "ota_update",
        }
        
        action = action_map.get(command_type, command_type)
        mqtt_command = {"action": action}
        
        if command_data.get("durationMs"):
            mqtt_command["durationMs"] = command_data["durationMs"]
        if command_data.get("amountMl"):
            mqtt_command["amountMl"] = command_data["amountMl"]
        if command_data.get("intervalMs"):
            mqtt_command["intervalMs"] = command_data["intervalMs"]
        if command_data.get("url"):
            mqtt_command["url"] = command_data["url"]
        
        success = await publish_device_command(device_id, mqtt_command)
        return success
        
    except Exception as e:
        logger.error(f"Failed to publish command via MQTT: {e}")
        return False


async def post(device_id: str, body: dict, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """Create a command for a device (force reading, pump, etc.)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")

    logger.info(f"Create command request - device={device_id} user_uid={user_uid}")

    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        logger.info(f"Device lookup failed for {device_id}")
        return {"error": "Device not found"}, 404

    command = await db.create_command(
        device_id=device_id,
        command_type=body["type"],
        requested_by=user_uid,
        duration_ms=body.get("durationMs"),
        amount_ml=body.get("amountMl"),
    )
    
    result = command.to_dict()
    result["deliveryMethod"] = "mqtt"
    
    # Try to deliver command immediately via MQTT
    try:
        success = await _publish_command_via_mqtt(device_id, body["type"], body)
        if success:
            await db.update_command_status(command.id, "sent")
            result["status"] = "sent"
            logger.info(f"Command {command.id} delivered via MQTT to {device_id}")
        else:
            result["deliveryMethod"] = "poll"
            logger.warning(f"Command {command.id} will be delivered via polling for {device_id}")
    except Exception as e:
        logger.warning(f"Could not deliver command via MQTT: {e}. Will use polling.")
        result["deliveryMethod"] = "poll"
    
    return result, 201


async def get(device_id: str, limit: int = 100, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """List commands (for UI history/debug)."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    commands = await db.get_commands(device_id, limit=limit)
    
    return {
        "count": len(commands),
        "items": [c.to_dict() for c in commands],
    }, 200


async def pending_get(device_id: str, max: int = 5, user: dict = None, token_info: dict = None) -> tuple[dict, int]:
    """ESP32 polls pending commands."""
    device_info = token_info or user or {}
    auth_device_id = device_info.get("device_id")
    
    if auth_device_id != device_id:
        return {"error": "Device key doesn't match device ID"}, 401
    
    commands = await db.get_commands(device_id, status="pending", limit=max)
    
    # Mark as sent
    for cmd in commands:
        await db.update_command_status(cmd.id, "sent")
    
    return {
        "count": len(commands),
        "items": [c.to_dict() for c in commands],
    }, 200


async def command_id_ack_post(
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
    
    command = await db.update_command_status(
        command_id=command_id,
        status=body["status"],
        error_message=body.get("errorMessage"),
    )
    
    if not command:
        return {"error": "Command not found"}, 404
    
    return command.to_dict(), 200
