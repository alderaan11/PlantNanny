"""
MQTT Handler for PlantNanny Server
Subscribes to sensor data topics and stores readings
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
    Handles MQTT connections and subscriptions for receiving sensor data from ESP32 devices.
    
    Topics:
        plantnanny/{deviceId}/sensors - Periodic sensor readings
        plantnanny/{deviceId}/status  - Device online/offline status
    """
    
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
    
    async def _handle_message(self, topic: str, payload: bytes):
        """Process incoming MQTT messages."""
        try:
            topic_parts = topic.split("/")
            if len(topic_parts) < 3 or topic_parts[0] != "plantnanny":
                logger.warning(f"Ignoring message on unexpected topic: {topic}")
                return
            
            device_id = topic_parts[1]
            message_type = topic_parts[2]
            
            if message_type == "sensors":
                data = json.loads(payload.decode("utf-8"))
                logger.info(f"Received sensor data from {device_id}: {data}")
                
                # Validate and normalize the reading
                reading = {
                    "temperatureC": data.get("temperatureC"),
                    "humidityPct": data.get("humidityPct"),
                    "luminosityPct": data.get("luminosityPct"),
                    "ts": data.get("ts") or datetime.now(timezone.utc).isoformat(),
                }
                
                if self._on_reading_callback:
                    await self._on_reading_callback(device_id, reading)
                
                # Notify real-time subscribers
                await self._notify_realtime_subscribers(device_id, reading)
                    
            elif message_type == "status":
                status = payload.decode("utf-8")
                logger.info(f"Device {device_id} status: {status}")
                
                if self._on_status_callback:
                    await self._on_status_callback(device_id, status)
                    
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON payload: {e}")
        except Exception as e:
            logger.exception(f"Error handling MQTT message: {e}")
    
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
                    # Subscribe to all plantnanny topics
                    await client.subscribe("plantnanny/+/sensors")
                    await client.subscribe("plantnanny/+/status")
                    logger.info("Subscribed to plantnanny/+/sensors and plantnanny/+/status")
                    
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
    
    async def stop(self):
        """Stop the MQTT subscriber."""
        self._running = False
        if self._task:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
        logger.info("MQTT handler stopped")


# Global handler instance
_mqtt_handler: Optional[MQTTHandler] = None


def get_mqtt_handler() -> Optional[MQTTHandler]:
    """Get the global MQTT handler instance."""
    return _mqtt_handler


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
        
        # Update device lastSeen
        devices_store[device_id]["lastSeen"] = datetime.now(timezone.utc).isoformat()
        
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
