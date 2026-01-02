"""
In-memory storage for development/testing.
Replace with a real database (PostgreSQL, Firebase, etc.) for production.
"""
import uuid
from datetime import datetime, timezone, timedelta
from typing import Dict, List, Any
import random


# In-memory stores
devices_store: Dict[str, Dict[str, Any]] = {}
readings_store: Dict[str, List[Dict[str, Any]]] = {}
commands_store: Dict[str, List[Dict[str, Any]]] = {}

# Device API keys for DeviceKey authentication
# Format: { "api_key": "device_id" }
device_keys: Dict[str, str] = {
    # Example device key for testing
    "test-device-key-esp32-001": "esp32-001",
}


def generate_id() -> str:
    """Generate a unique ID."""
    return str(uuid.uuid4())


def reset_stores() -> None:
    """Reset all stores (useful for testing)."""
    global devices_store, readings_store, commands_store
    devices_store.clear()
    readings_store.clear()
    commands_store.clear()


def seed_fake_data() -> None:
    """
    Seed the stores with fake data for development/testing.
    Creates devices, readings history, and sample commands.
    """
    now = datetime.now(timezone.utc)
    
    # --- Fake Devices ---
    fake_devices = [
        {
            "deviceId": "esp32-tomato",
            "name": "Tomates du balcon",
            "ownerUid": "user1",
            "createdAt": (now - timedelta(days=30)).isoformat(),
            "lastSeen": (now - timedelta(minutes=5)).isoformat(),
            "firmwareVersion": "1.2.3",
        },
        {
            "deviceId": "esp32-basil",
            "name": "Basilic cuisine",
            "ownerUid": "user1",
            "createdAt": (now - timedelta(days=15)).isoformat(),
            "lastSeen": (now - timedelta(minutes=2)).isoformat(),
            "firmwareVersion": "1.2.3",
        },
        {
            "deviceId": "esp32-fern",
            "name": "Fougère salon",
            "ownerUid": "user1",
            "createdAt": (now - timedelta(days=7)).isoformat(),
            "lastSeen": (now - timedelta(hours=1)).isoformat(),
            "firmwareVersion": "1.2.0",
        },
    ]
    
    for device in fake_devices:
        device_id = device["deviceId"]
        devices_store[device_id] = device
        device_keys[f"device-key-{device_id}"] = device_id
        readings_store[device_id] = []
        commands_store[device_id] = []
    
    # --- Fake Readings (last 24 hours, every 15 minutes) ---
    for device_id in ["esp32-tomato", "esp32-basil", "esp32-fern"]:
        readings = []
        base_temp = random.uniform(18, 24)
        base_humidity = random.uniform(40, 70)
        base_luminosity = random.uniform(30, 80)
        
        for i in range(96):  # 24h * 4 readings/hour
            ts = now - timedelta(minutes=15 * (95 - i))
            
            # Add some variation
            hour = ts.hour
            # Temperature varies with time of day
            temp_variation = 3 * (1 - abs(hour - 14) / 14)  # Peak at 2 PM
            # Luminosity varies with daylight
            if 6 <= hour <= 20:
                lum_variation = 40 * (1 - abs(hour - 13) / 7)
            else:
                lum_variation = -base_luminosity * 0.8
            
            reading = {
                "id": generate_id(),
                "deviceId": device_id,
                "ts": ts.isoformat(),
                "temperatureC": round(base_temp + temp_variation + random.uniform(-1, 1), 1),
                "humidityPct": round(max(0, min(100, base_humidity + random.uniform(-5, 5))), 1),
                "luminosityPct": round(max(0, min(100, base_luminosity + lum_variation + random.uniform(-5, 5))), 1),
            }
            readings.append(reading)
        
        readings_store[device_id] = readings
    
    # --- Fake Commands ---
    sample_commands = [
        {
            "id": generate_id(),
            "deviceId": "esp32-tomato",
            "type": "pump_water",
            "status": "done",
            "createdAt": (now - timedelta(hours=6)).isoformat(),
            "updatedAt": (now - timedelta(hours=6, minutes=-1)).isoformat(),
            "durationMs": 5000,
            "amountMl": 50,
            "requestedBy": "user1",
            "errorMessage": None,
        },
        {
            "id": generate_id(),
            "deviceId": "esp32-tomato",
            "type": "force_reading",
            "status": "done",
            "createdAt": (now - timedelta(hours=2)).isoformat(),
            "updatedAt": (now - timedelta(hours=2, minutes=-1)).isoformat(),
            "durationMs": None,
            "amountMl": None,
            "requestedBy": "user1",
            "errorMessage": None,
        },
        {
            "id": generate_id(),
            "deviceId": "esp32-basil",
            "type": "pump_water",
            "status": "pending",
            "createdAt": (now - timedelta(minutes=10)).isoformat(),
            "updatedAt": (now - timedelta(minutes=10)).isoformat(),
            "durationMs": 3000,
            "amountMl": 30,
            "requestedBy": "user1",
            "errorMessage": None,
        },
    ]
    
    for cmd in sample_commands:
        device_id = cmd["deviceId"]
        commands_store[device_id].append(cmd)
    
    print(f"✓ Seeded {len(fake_devices)} devices")
    print(f"✓ Seeded {sum(len(r) for r in readings_store.values())} readings")
    print(f"✓ Seeded {sum(len(c) for c in commands_store.values())} commands")
