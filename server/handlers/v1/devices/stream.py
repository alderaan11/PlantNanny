"""Realtime stream handler - /v1/devices/{deviceId}/stream"""
import json
import time
from starlette.responses import StreamingResponse

from storage import devices_store


def get(device_id: str, user: dict = None, token_info: dict = None):
    """Server-Sent Events stream for realtime updates."""
    info = token_info or user or {}
    user_uid = info.get("uid", "")
    
    device = devices_store.get(device_id)
    if not device or device.get("ownerUid") != user_uid:
        return {"error": "Device not found"}, 404
    
    def generate():
        """Generate SSE events."""
        yield f"event: connected\ndata: {json.dumps({'deviceId': device_id})}\n\n"
        
        while True:
            time.sleep(30)
            yield f"event: ping\ndata: {json.dumps({'ts': time.time()})}\n\n"
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
