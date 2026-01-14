"""Commands handlers - /v1/devices/{deviceId}/commands"""
from datetime import datetime, timezone
import logging
import asyncio

from storage import devices_store, commands_store, generate_id

logger = logging.getLogger("plant_nanny.commands")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


async def _publish_command_via_mqtt(device_id: str, command_type: str, command_data: dict) -> bool:
    """
    Publish command to device via MQTT for immediate delivery.
    
    This is the preferred method for command delivery as it's more efficient
    than HTTP polling. The device subscribes to its command topic and receives
    commands in real-time.
    """
    try:
        from mqtt_handler import publish_device_command
        
        # Map command types to MQTT action format
        action_map = {
            "force_reading": "send_now",
            "pump_water": "pump_water",
            "set_interval": "set_interval",
            "restart": "restart",
            "ota_update": "ota_update",
        }
        
        action = action_map.get(command_type, command_type)
        
        mqtt_command = {"action": action}
        
        # Add command-specific parameters
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
        "deliveryMethod": "mqtt",  # Track how command was delivered
    }
    
    if device_id not in commands_store:
        commands_store[device_id] = []
    commands_store[device_id].append(command)
    
    # Try to deliver command immediately via MQTT
    # This is more efficient than waiting for the device to poll
    try:
        loop = asyncio.get_event_loop()
        if loop.is_running():
            async def deliver_and_update():
                success = await _publish_command_via_mqtt(device_id, body["type"], body)
                if success:
                    command["status"] = "sent"
                    command["updatedAt"] = datetime.now(timezone.utc).isoformat()
                    logger.info(f"Command {command_id} delivered via MQTT to {device_id}")
                else:
                    command["deliveryMethod"] = "poll"  # Fall back to polling
                    logger.warning(f"Command {command_id} will be delivered via polling for {device_id}")
            
            asyncio.create_task(deliver_and_update())
        else:
            # Synchronous context - run directly
            success = loop.run_until_complete(_publish_command_via_mqtt(device_id, body["type"], body))
            if success:
                command["status"] = "sent"
                command["updatedAt"] = datetime.now(timezone.utc).isoformat()
    except Exception as e:
        logger.warning(f"Could not deliver command via MQTT: {e}. Will use polling.")
        command["deliveryMethod"] = "poll"
    
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
