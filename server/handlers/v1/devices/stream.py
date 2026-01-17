"""Realtime stream handler - /v1/devices/{deviceId}/stream"""
import asyncio
import json
import time
from datetime import datetime, timezone
from starlette.responses import StreamingResponse

import database as db
from mqtt_handler import get_mqtt_handler, force_device_reading


# Maximum age of last reading before requesting a fresh one (in seconds)
MAX_READING_AGE_SECONDS = 120  # 2 minutes


def _reading_is_stale(reading) -> bool:
    """Check if a reading is too old and needs to be refreshed."""
    ts = reading.ts if hasattr(reading, 'ts') else reading.get("ts")
    if not ts:
        return True
    
    try:
        # Handle datetime objects
        if isinstance(ts, datetime):
            reading_time = ts if ts.tzinfo else ts.replace(tzinfo=timezone.utc)
        # Handle both ISO format and Unix timestamp
        elif isinstance(ts, (int, float)):
            reading_time = datetime.fromtimestamp(ts, tz=timezone.utc)
        else:
            reading_time = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        
        age = (datetime.now(timezone.utc) - reading_time).total_seconds()
        return age > MAX_READING_AGE_SECONDS
    except:
        return True


async def get(device_id: str, user: dict = None, token_info: dict = None):
    """
    Server-Sent Events stream for realtime updates.
    
    When a client connects:
    1. If there's a recent reading (< 2 min old), send it immediately
    2. If no recent reading exists, send a force_reading command to the device
    3. Stream any new readings as they arrive via MQTT
    
    This ensures the frontend always gets data quickly after connecting.
    """
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = await db.get_device_for_owner(device_id, user_uid)
    if not device:
        return {"error": "Device not found"}, 404
    
    mqtt_handler = get_mqtt_handler()
    
    async def generate():
        """Generate SSE events."""
        # Send connected event
        yield f"event: connected\ndata: {json.dumps({'deviceId': device_id})}\n\n"
        
        # Check if we have a recent reading from DB
        last_reading = await db.get_last_reading(device_id)
        need_fresh_reading = True
        
        if last_reading:
            # Send the last reading immediately
            yield f"event: reading\ndata: {json.dumps(last_reading.to_dict())}\n\n"
            
            # Check if it's fresh enough
            need_fresh_reading = _reading_is_stale(last_reading)
        
        # If no recent reading, request fresh data from device via MQTT
        if need_fresh_reading:
            yield f"event: requesting_data\ndata: {json.dumps({'message': 'Requesting fresh data from device...'})}\n\n"
            
            # Send force reading command
            await force_device_reading(device_id)
        
        # Subscribe to MQTT real-time updates if handler is available
        queue = None
        if mqtt_handler:
            queue = await mqtt_handler.subscribe_realtime(device_id)
        
        try:
            ping_interval = 30  # seconds
            last_ping = time.time()
            
            # Timeout for waiting for first reading after force request
            force_reading_timeout = 10  # seconds
            force_reading_start = time.time() if need_fresh_reading else None
            
            while True:
                # Check for new MQTT messages
                if queue:
                    try:
                        # Wait for a message with a short timeout
                        reading = await asyncio.wait_for(queue.get(), timeout=1.0)
                        yield f"event: reading\ndata: {json.dumps(reading)}\n\n"
                        last_ping = time.time()  # Reset ping timer on activity
                        force_reading_start = None  # Got data, reset timeout
                    except asyncio.TimeoutError:
                        pass
                else:
                    # No MQTT, just wait
                    await asyncio.sleep(1)
                
                # Check if we're still waiting for force reading response
                if force_reading_start and (time.time() - force_reading_start > force_reading_timeout):
                    yield f"event: timeout\ndata: {json.dumps({'message': 'Device did not respond. It may be offline.'})}\n\n"
                    force_reading_start = None
                
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
