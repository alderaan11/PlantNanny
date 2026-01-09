"""Realtime stream handler - /v1/devices/{deviceId}/stream"""
import asyncio
import json
import time
from starlette.responses import StreamingResponse

from storage import devices_store, readings_store
from mqtt_handler import get_mqtt_handler


async def get(device_id: str, user: dict = None, token_info: dict = None):
    """Server-Sent Events stream for realtime updates."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    mqtt_handler = get_mqtt_handler()
    
    async def generate():
        """Generate SSE events."""
        # Send connected event
        yield f"event: connected\ndata: {json.dumps({'deviceId': device_id})}\n\n"
        
        # Send the last reading if available
        device_readings = readings_store.get(device_id, [])
        if device_readings:
            sorted_readings = sorted(device_readings, key=lambda r: r.get("ts", ""), reverse=True)
            last_reading = sorted_readings[0]
            yield f"event: reading\ndata: {json.dumps(last_reading)}\n\n"
        
        # Subscribe to MQTT real-time updates if handler is available
        queue = None
        if mqtt_handler:
            queue = await mqtt_handler.subscribe_realtime(device_id)
        
        try:
            ping_interval = 30  # seconds
            last_ping = time.time()
            
            while True:
                # Check for new MQTT messages
                if queue:
                    try:
                        # Wait for a message with a short timeout
                        reading = await asyncio.wait_for(queue.get(), timeout=1.0)
                        yield f"event: reading\ndata: {json.dumps(reading)}\n\n"
                        last_ping = time.time()  # Reset ping timer on activity
                    except asyncio.TimeoutError:
                        pass
                else:
                    # No MQTT, just wait
                    await asyncio.sleep(1)
                
                # Send periodic ping to keep connection alive
                current_time = time.time()
                if current_time - last_ping >= ping_interval:
                    yield f"event: ping\ndata: {json.dumps({'ts': current_time})}\n\n"
                    last_ping = current_time
                    
        finally:
            # Cleanup subscription
            if mqtt_handler and queue:
                await mqtt_handler.unsubscribe_realtime(device_id, queue)
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
