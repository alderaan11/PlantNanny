"""
MQTT Handler for PlantNanny Server
Subscribes to sensor data topics and publishes commands to ESP32 devices

Topic Structure:
    devices/<device_id>/data     - ESP32 → Server (telemetry)
    devices/<device_id>/command  - Server → ESP32 (commands)
    devices/<device_id>/status   - Device status (online/offline via LWT)

Legacy Topics (for backward compatibility):
    plantnanny/<device_id>/sensors - Periodic sensor readings
    plantnanny/<device_id>/status  - Device status
"""
import asyncio
import json
import logging
from datetime import datetime, timezone
from typing import Optional, Callable, Awaitable, Set, Dict
from collections import defaultdict

try:
    import aiomqtt
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False

logger = logging.getLogger("plant_nanny.mqtt")


class MQTTHandler:
    """
    Handles MQTT connections and subscriptions for receiving sensor data from ESP32 devices
    and publishing commands to them.
    
    Topics (new structure):
        devices/{deviceId}/data     - Sensor readings (JSON)
        devices/{deviceId}/command  - Commands to device (JSON)
        devices/{deviceId}/status   - Device online/offline status (JSON)
    
    Topics (legacy):
        plantnanny/{deviceId}/sensors - Periodic sensor readings
        plantnanny/{deviceId}/status  - Device online/offline status
    """
    
    # QoS level for reliable delivery
    MQTT_QOS = 1
    
    def __init__(
        self,
        broker_host: str = "localhost",
        broker_port: int = 1883,
        username: Optional[str] = None,
        password: Optional[str] = None,
    ):
        self.broker_host = broker_host
        self.broker_port = broker_port
        self.username = username
        self.password = password
        self._running = False
        self._task: Optional[asyncio.Task] = None
        self._client: Optional[aiomqtt.Client] = None
        self._on_reading_callback: Optional[Callable[[str, dict], Awaitable[None]]] = None
        self._on_status_callback: Optional[Callable[[str, str], Awaitable[None]]] = None
        
        # Real-time subscriptions for SSE streams
        # device_id -> set of asyncio.Queue for real-time updates
        self._realtime_subscribers: Dict[str, Set[asyncio.Queue]] = defaultdict(set)
        self._lock = asyncio.Lock()
    
    def on_reading(self, callback: Callable[[str, dict], Awaitable[None]]):
        """Register callback for sensor readings. Callback receives (device_id, reading_data)."""
        self._on_reading_callback = callback
    
    def on_status(self, callback: Callable[[str, str], Awaitable[None]]):
        """Register callback for device status updates. Callback receives (device_id, status)."""
        self._on_status_callback = callback
    
    async def subscribe_realtime(self, device_id: str) -> asyncio.Queue:
        """
        Subscribe to real-time updates for a device.
        Returns an asyncio.Queue that will receive reading dicts.
        """
        queue: asyncio.Queue = asyncio.Queue()
        async with self._lock:
            self._realtime_subscribers[device_id].add(queue)
        logger.debug(f"Added realtime subscriber for {device_id}")
        return queue
    
    async def unsubscribe_realtime(self, device_id: str, queue: asyncio.Queue):
        """Unsubscribe from real-time updates."""
        async with self._lock:
            self._realtime_subscribers[device_id].discard(queue)
            if not self._realtime_subscribers[device_id]:
                del self._realtime_subscribers[device_id]
        logger.debug(f"Removed realtime subscriber for {device_id}")
    
    async def _notify_realtime_subscribers(self, device_id: str, reading: dict):
        """Notify all real-time subscribers of a new reading."""
        async with self._lock:
            subscribers = list(self._realtime_subscribers.get(device_id, []))
        
        for queue in subscribers:
            try:
                queue.put_nowait(reading)
            except asyncio.QueueFull:
                # Drop old messages if queue is full
                try:
                    queue.get_nowait()
                    queue.put_nowait(reading)
                except:
                    pass
    
    async def publish_command(self, device_id: str, command: dict) -> bool:
        """
        Publish a command to a specific device.
        
        Args:
            device_id: Target device ID
            command: Command dict with 'action' and optional parameters
                     e.g., {"action": "send_now"} or {"action": "pump_water", "durationMs": 5000}
        
        Returns:
            True if published successfully, False otherwise
        """
        if not self._client:
            logger.warning("Cannot publish command: MQTT client not connected")
            return False
        
        try:
            # Try new topic structure first
            topic = f"devices/{device_id}/command"
            payload = json.dumps(command)
            
            await self._client.publish(topic, payload, qos=self.MQTT_QOS)
            logger.info(f"Published command to {device_id}: {command}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to publish command to {device_id}: {e}")
            return False
    
    async def force_device_reading(self, device_id: str) -> bool:
        """
        Send a 'send_now' command to force a device to send its current sensor reading.
        
        This is the recommended way to get immediate data from a device after registration
        or when real-time data is needed.
        
        Args:
            device_id: Target device ID
            
        Returns:
            True if command published successfully
        """
        return await self.publish_command(device_id, {"action": "send_now"})
    
    async def _handle_message(self, topic: str, payload: bytes):
        """Process incoming MQTT messages."""
        try:
            topic_parts = topic.split("/")
            
            # Handle new topic structure: devices/<device_id>/data or devices/<device_id>/status
            if len(topic_parts) >= 3 and topic_parts[0] == "devices":
                device_id = topic_parts[1]
                message_type = topic_parts[2]
                
                if message_type == "data":
                    await self._handle_sensor_data(device_id, payload)
                elif message_type == "status":
                    await self._handle_status(device_id, payload)
                return
            
            # Handle legacy topic structure: plantnanny/<device_id>/sensors or status
            if len(topic_parts) >= 3 and topic_parts[0] == "plantnanny":
                device_id = topic_parts[1]
                message_type = topic_parts[2]
                
                if message_type == "sensors":
                    await self._handle_sensor_data(device_id, payload)
                elif message_type == "status":
                    await self._handle_status(device_id, payload)
                return
            
            logger.warning(f"Ignoring message on unexpected topic: {topic}")
                    
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON payload: {e}")
        except Exception as e:
            logger.exception(f"Error handling MQTT message: {e}")
    
    async def _handle_sensor_data(self, device_id: str, payload: bytes):
        """Handle incoming sensor data from a device."""
        data = json.loads(payload.decode("utf-8"))
        logger.info(f"Received sensor data from {device_id}: {data}")
        
        # Validate and normalize the reading
        reading = {
            "temperatureC": data.get("temperatureC"),
            "humidityPct": data.get("humidityPct"),
            "luminosityPct": data.get("luminosityPct"),
            "ts": data.get("ts") or datetime.now(timezone.utc).isoformat(),
            "uptime": data.get("uptime"),
        }
        
        if self._on_reading_callback:
            await self._on_reading_callback(device_id, reading)
        
        # Notify real-time subscribers
        await self._notify_realtime_subscribers(device_id, reading)
    
    async def _handle_status(self, device_id: str, payload: bytes):
        """Handle device status update (online/offline from LWT)."""
        try:
            # Try JSON format first (new format)
            data = json.loads(payload.decode("utf-8"))
            status = data.get("status", "unknown")
        except json.JSONDecodeError:
            # Fall back to plain text (legacy format)
            status = payload.decode("utf-8")
        
        logger.info(f"Device {device_id} status: {status}")
        
        if self._on_status_callback:
            await self._on_status_callback(device_id, status)
    
    async def start(self):
        """Start the MQTT subscriber."""
        if not MQTT_AVAILABLE:
            logger.warning("aiomqtt not installed. MQTT functionality disabled.")
            logger.warning("Install with: pip install aiomqtt")
            return
        
        self._running = True
        self._task = asyncio.create_task(self._run())
        logger.info(f"MQTT handler started, connecting to {self.broker_host}:{self.broker_port}")
    
    async def _run(self):
        """Main MQTT loop with reconnection logic."""
        while self._running:
            try:
                async with aiomqtt.Client(
                    hostname=self.broker_host,
                    port=self.broker_port,
                    username=self.username,
                    password=self.password,
                ) as client:
                    # Store client reference for publishing commands
                    self._client = client
                    
                    # Subscribe to new topic structure (devices/<id>/data, devices/<id>/status)
                    await client.subscribe("devices/+/data", qos=self.MQTT_QOS)
                    await client.subscribe("devices/+/status", qos=self.MQTT_QOS)
                    logger.info("Subscribed to devices/+/data and devices/+/status")
                    
                    # Subscribe to legacy topics for backward compatibility
                    await client.subscribe("plantnanny/+/sensors", qos=self.MQTT_QOS)
                    await client.subscribe("plantnanny/+/status", qos=self.MQTT_QOS)
                    logger.info("Subscribed to plantnanny/+/sensors and plantnanny/+/status (legacy)")
                    
                    async for message in client.messages:
                        await self._handle_message(
                            str(message.topic),
                            message.payload
                        )
                        
            except asyncio.CancelledError:
                logger.info("MQTT handler cancelled")
                break
            except Exception as e:
                if self._running:
                    logger.error(f"MQTT connection error: {e}. Reconnecting in 5s...")
                    await asyncio.sleep(5)
            finally:
                self._client = None
    
    async def stop(self):
        """Stop the MQTT subscriber."""
        self._running = False
        if self._task:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
        self._client = None
        logger.info("MQTT handler stopped")


# Global handler instance
_mqtt_handler: Optional[MQTTHandler] = None


def get_mqtt_handler() -> Optional[MQTTHandler]:
    """Get the global MQTT handler instance."""
    return _mqtt_handler


async def force_device_reading(device_id: str) -> bool:
    """
    Send a force reading command to a device via MQTT.
    
    This is the recommended way to get immediate data from a device after registration
    or when real-time data is needed. The device will respond by publishing its
    current sensor readings.
    
    Args:
        device_id: Target device ID
        
    Returns:
        True if command was published successfully, False otherwise
    """
    if not _mqtt_handler:
        logger.warning("MQTT handler not initialized, cannot force device reading")
        return False
    
    return await _mqtt_handler.force_device_reading(device_id)


async def publish_device_command(device_id: str, command: dict) -> bool:
    """
    Publish a command to a device via MQTT.
    
    Command examples:
        {"action": "send_now"}                              - Force immediate sensor reading
        {"action": "pump_water", "durationMs": 5000}        - Activate water pump
        {"action": "set_interval", "intervalMs": 30000}     - Change publish interval
        {"action": "restart"}                               - Restart device
        {"action": "ota_update", "url": "http://..."}       - Trigger OTA update
    
    Args:
        device_id: Target device ID
        command: Command dictionary with 'action' and optional parameters
        
    Returns:
        True if command was published successfully
    """
    if not _mqtt_handler:
        logger.warning("MQTT handler not initialized, cannot publish command")
        return False
    
    return await _mqtt_handler.publish_command(device_id, command)


async def setup_mqtt_handler(
    broker_host: str = "localhost",
    broker_port: int = 1883,
    username: Optional[str] = None,
    password: Optional[str] = None,
) -> MQTTHandler:
    """
    Setup and start the global MQTT handler.
    
    Args:
        broker_host: MQTT broker hostname
        broker_port: MQTT broker port
        username: Optional MQTT username
        password: Optional MQTT password
    
    Returns:
        The configured MQTTHandler instance
    """
    global _mqtt_handler
    
    from storage import readings_store, devices_store
    
    _mqtt_handler = MQTTHandler(
        broker_host=broker_host,
        broker_port=broker_port,
        username=username,
        password=password,
    )
    
    async def on_reading(device_id: str, reading: dict):
        """Store received sensor reading."""
        from storage import generate_id
        
        # Check if device exists, create if not
        if device_id not in devices_store:
            logger.info(f"Auto-registering device {device_id}")
            devices_store[device_id] = {
                "deviceId": device_id,
                "name": f"Device {device_id}",
                "ownerUid": None,
            }
        
        # Add id and deviceId to the reading
        reading["id"] = generate_id()
        reading["deviceId"] = device_id
        
        # Update device lastSeen and mark as online
        devices_store[device_id]["lastSeen"] = datetime.now(timezone.utc).isoformat()
        devices_store[device_id]["lastStatus"] = "online"
        
        # Store the reading
        if device_id not in readings_store:
            readings_store[device_id] = []
        
        readings_store[device_id].append(reading)
        
        # Keep only last 1000 readings per device
        if len(readings_store[device_id]) > 1000:
            readings_store[device_id] = readings_store[device_id][-1000:]
        
        logger.debug(f"Stored reading for {device_id}: {reading}")
    
    async def on_status(device_id: str, status: str):
        """Update device status."""
        if device_id in devices_store:
            devices_store[device_id]["lastStatus"] = status
            devices_store[device_id]["lastSeen"] = datetime.now(timezone.utc).isoformat()
            logger.debug(f"Updated status for {device_id}: {status}")
    
    _mqtt_handler.on_reading(on_reading)
    _mqtt_handler.on_status(on_status)
    
    await _mqtt_handler.start()
    
    return _mqtt_handler


async def shutdown_mqtt_handler():
    """Shutdown the global MQTT handler."""
    global _mqtt_handler
    if _mqtt_handler:
        await _mqtt_handler.stop()
        _mqtt_handler = None
