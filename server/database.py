"""
Database service layer for PlantNanny.
Provides async database operations using SQLAlchemy with PostgreSQL.
"""
import os
import logging
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Tuple
from contextlib import asynccontextmanager
import random
import uuid

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select, delete, update, func, desc, asc, and_
from sqlalchemy.orm import selectinload

from models import Base, Device, Reading, Command, Firmware, DeviceApiKey

logger = logging.getLogger("plant_nanny.db")

# Database URL from environment or default
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://plantnanny:plantnanny_secret@localhost:5432/plantnanny"
)

# Global engine and session factory
_engine = None
_async_session_factory = None


async def init_db(database_url: Optional[str] = None) -> None:
    """Initialize the database connection and create tables."""
    global _engine, _async_session_factory
    
    url = database_url or DATABASE_URL
    logger.info(f"Initializing database: {url.split('@')[-1]}")  # Log without credentials
    
    _engine = create_async_engine(
        url,
        echo=os.getenv("DB_ECHO", "").lower() == "true",
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True,
    )
    
    _async_session_factory = async_sessionmaker(
        _engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )
    
    # Create all tables
    async with _engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    logger.info("Database initialized successfully")


async def close_db() -> None:
    """Close database connection."""
    global _engine
    if _engine:
        await _engine.dispose()
        logger.info("Database connection closed")


@asynccontextmanager
async def get_session() -> AsyncSession:
    """Get an async database session."""
    if not _async_session_factory:
        raise RuntimeError("Database not initialized. Call init_db() first.")
    
    session = _async_session_factory()
    try:
        yield session
        await session.commit()
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()


# ===================
# Device Operations
# ===================

async def get_all_devices() -> List[Device]:
    """Get all devices (for admin operations like OTA broadcast)."""
    async with get_session() as session:
        result = await session.execute(select(Device))
        return list(result.scalars().all())


async def get_devices_by_owner(owner_uid: str) -> List[Device]:
    """Get all devices for a user."""
    async with get_session() as session:
        result = await session.execute(
            select(Device).where(Device.owner_uid == owner_uid)
        )
        return list(result.scalars().all())


async def get_device(device_id: str) -> Optional[Device]:
    """Get a device by ID."""
    async with get_session() as session:
        result = await session.execute(
            select(Device).where(Device.device_id == device_id)
        )
        return result.scalar_one_or_none()


async def get_device_for_owner(device_id: str, owner_uid: str) -> Optional[Device]:
    """Get a device only if it belongs to the user."""
    async with get_session() as session:
        result = await session.execute(
            select(Device).where(
                and_(Device.device_id == device_id, Device.owner_uid == owner_uid)
            )
        )
        return result.scalar_one_or_none()


async def create_device(
    device_id: str,
    name: str,
    owner_uid: str,
    firmware_version: str = "1.0.0",
) -> Device:
    """Create a new device."""
    async with get_session() as session:
        now = datetime.now(timezone.utc)
        device = Device(
            device_id=device_id,
            name=name,
            owner_uid=owner_uid,
            created_at=now,
            last_seen=now,
            firmware_version=firmware_version,
            last_status="unknown",
        )
        session.add(device)
        await session.flush()
        
        # Create API key for the device
        api_key = DeviceApiKey(
            api_key=f"device-key-{device_id}",
            device_id=device_id,
            created_at=now,
        )
        session.add(api_key)
        
        return device


async def update_device(device_id: str, **kwargs) -> Optional[Device]:
    """Update device fields."""
    async with get_session() as session:
        result = await session.execute(
            select(Device).where(Device.device_id == device_id)
        )
        device = result.scalar_one_or_none()
        if device:
            for key, value in kwargs.items():
                if hasattr(device, key):
                    setattr(device, key, value)
        return device


async def update_device_last_seen(device_id: str) -> None:
    """Update device's last_seen timestamp."""
    async with get_session() as session:
        await session.execute(
            update(Device)
            .where(Device.device_id == device_id)
            .values(last_seen=datetime.now(timezone.utc))
        )


async def delete_device(device_id: str, owner_uid: str) -> bool:
    """Delete a device (cascades to readings, commands, api_key)."""
    async with get_session() as session:
        result = await session.execute(
            delete(Device).where(
                and_(Device.device_id == device_id, Device.owner_uid == owner_uid)
            )
        )
        return result.rowcount > 0


# ===================
# Reading Operations
# ===================

async def create_reading(
    device_id: str,
    temperature_c: Optional[float] = None,
    humidity_pct: Optional[float] = None,
    luminosity_pct: Optional[float] = None,
    soil_moisture_pct: Optional[float] = None,
    ts: Optional[datetime] = None,
) -> Reading:
    """Create a new sensor reading."""
    async with get_session() as session:
        reading = Reading(
            id=str(uuid.uuid4()),
            device_id=device_id,
            ts=ts or datetime.now(timezone.utc),
            temperature_c=temperature_c,
            humidity_pct=humidity_pct,
            luminosity_pct=luminosity_pct,
            soil_moisture_pct=soil_moisture_pct,
        )
        session.add(reading)
        await session.flush()
        
        # Update device last_seen
        await session.execute(
            update(Device)
            .where(Device.device_id == device_id)
            .values(last_seen=datetime.now(timezone.utc))
        )
        
        return reading


async def get_readings(
    device_id: str,
    from_dt: Optional[datetime] = None,
    to_dt: Optional[datetime] = None,
    limit: int = 200,
    order: str = "desc",
) -> List[Reading]:
    """Get readings for a device with optional filtering."""
    async with get_session() as session:
        query = select(Reading).where(Reading.device_id == device_id)
        
        if from_dt:
            query = query.where(Reading.ts >= from_dt)
        if to_dt:
            query = query.where(Reading.ts < to_dt)
        
        if order == "desc":
            query = query.order_by(desc(Reading.ts))
        else:
            query = query.order_by(asc(Reading.ts))
        
        query = query.limit(limit)
        
        result = await session.execute(query)
        return list(result.scalars().all())


async def get_last_reading(device_id: str) -> Optional[Reading]:
    """Get the most recent reading for a device."""
    async with get_session() as session:
        result = await session.execute(
            select(Reading)
            .where(Reading.device_id == device_id)
            .order_by(desc(Reading.ts))
            .limit(1)
        )
        return result.scalar_one_or_none()


async def get_readings_aggregated(
    device_id: str,
    from_dt: Optional[datetime] = None,
    to_dt: Optional[datetime] = None,
) -> dict:
    """Get aggregated stats for readings."""
    async with get_session() as session:
        query = select(
            func.avg(Reading.temperature_c).label("avg_temp"),
            func.min(Reading.temperature_c).label("min_temp"),
            func.max(Reading.temperature_c).label("max_temp"),
            func.avg(Reading.humidity_pct).label("avg_humidity"),
            func.min(Reading.humidity_pct).label("min_humidity"),
            func.max(Reading.humidity_pct).label("max_humidity"),
            func.avg(Reading.luminosity_pct).label("avg_luminosity"),
            func.min(Reading.luminosity_pct).label("min_luminosity"),
            func.max(Reading.luminosity_pct).label("max_luminosity"),
            func.count().label("count"),
        ).where(Reading.device_id == device_id)
        
        if from_dt:
            query = query.where(Reading.ts >= from_dt)
        if to_dt:
            query = query.where(Reading.ts < to_dt)
        
        result = await session.execute(query)
        row = result.one()
        
        return {
            "temperature": {
                "avg": round(row.avg_temp, 1) if row.avg_temp else None,
                "min": round(row.min_temp, 1) if row.min_temp else None,
                "max": round(row.max_temp, 1) if row.max_temp else None,
            },
            "humidity": {
                "avg": round(row.avg_humidity, 1) if row.avg_humidity else None,
                "min": round(row.min_humidity, 1) if row.min_humidity else None,
                "max": round(row.max_humidity, 1) if row.max_humidity else None,
            },
            "luminosity": {
                "avg": round(row.avg_luminosity, 1) if row.avg_luminosity else None,
                "min": round(row.min_luminosity, 1) if row.min_luminosity else None,
                "max": round(row.max_luminosity, 1) if row.max_luminosity else None,
            },
            "count": row.count,
        }


# ===================
# Command Operations
# ===================

async def create_command(
    device_id: str,
    command_type: str,
    requested_by: Optional[str] = None,
    duration_ms: Optional[int] = None,
    amount_ml: Optional[int] = None,
) -> Command:
    """Create a new command."""
    async with get_session() as session:
        command = Command(
            id=str(uuid.uuid4()),
            device_id=device_id,
            type=command_type,
            status="pending",
            requested_by=requested_by,
            duration_ms=duration_ms,
            amount_ml=amount_ml,
        )
        session.add(command)
        await session.flush()
        return command


async def get_commands(
    device_id: str,
    status: Optional[str] = None,
    limit: int = 50,
) -> List[Command]:
    """Get commands for a device."""
    async with get_session() as session:
        query = select(Command).where(Command.device_id == device_id)
        
        if status:
            query = query.where(Command.status == status)
        
        query = query.order_by(desc(Command.created_at)).limit(limit)
        
        result = await session.execute(query)
        return list(result.scalars().all())


async def update_command_status(
    command_id: str,
    status: str,
    error_message: Optional[str] = None,
) -> Optional[Command]:
    """Update command status."""
    async with get_session() as session:
        result = await session.execute(
            select(Command).where(Command.id == command_id)
        )
        command = result.scalar_one_or_none()
        if command:
            command.status = status
            command.error_message = error_message
            command.updated_at = datetime.now(timezone.utc)
        return command


# ===================
# Firmware Operations
# ===================

async def get_latest_firmware() -> Optional[Firmware]:
    """Get the latest firmware version."""
    async with get_session() as session:
        result = await session.execute(
            select(Firmware).where(Firmware.is_latest == True)
        )
        return result.scalar_one_or_none()


async def get_firmware(version: str) -> Optional[Firmware]:
    """Get a specific firmware version."""
    async with get_session() as session:
        result = await session.execute(
            select(Firmware).where(Firmware.version == version)
        )
        return result.scalar_one_or_none()


async def set_firmware(
    version: str,
    url: Optional[str] = None,
    filename: Optional[str] = None,
    size: int = 0,
    checksum: Optional[str] = None,
    release_notes: Optional[str] = None,
) -> Firmware:
    """Create or update firmware version and set as latest."""
    async with get_session() as session:
        # Unset previous latest
        await session.execute(
            update(Firmware).values(is_latest=False)
        )
        
        # Check if version exists
        result = await session.execute(
            select(Firmware).where(Firmware.version == version)
        )
        firmware = result.scalar_one_or_none()
        
        if firmware:
            firmware.url = url
            firmware.filename = filename
            firmware.size = size
            firmware.checksum = checksum
            firmware.is_latest = True
            firmware.release_notes = release_notes
            firmware.uploaded_at = datetime.now(timezone.utc)
        else:
            firmware = Firmware(
                version=version,
                url=url,
                filename=filename,
                size=size,
                checksum=checksum,
                is_latest=True,
                release_notes=release_notes,
                uploaded_at=datetime.now(timezone.utc),
            )
            session.add(firmware)
        
        await session.flush()
        return firmware


async def get_all_firmware() -> List[Firmware]:
    """Get all firmware versions."""
    async with get_session() as session:
        result = await session.execute(
            select(Firmware).order_by(desc(Firmware.uploaded_at))
        )
        return list(result.scalars().all())


# ===================
# API Key Operations
# ===================

async def get_device_by_api_key(api_key: str) -> Optional[str]:
    """Get device_id for an API key."""
    async with get_session() as session:
        result = await session.execute(
            select(DeviceApiKey)
            .where(and_(DeviceApiKey.api_key == api_key, DeviceApiKey.is_active == True))
        )
        key = result.scalar_one_or_none()
        if key:
            # Update last_used
            key.last_used = datetime.now(timezone.utc)
            return key.device_id
        return None


# ===================
# Seeding
# ===================

async def seed_fake_data() -> None:
    """Seed the database with fake development data."""
    logger.info("Seeding fake data...")
    now = datetime.now(timezone.utc)
    
    # Check if data already exists
    async with get_session() as session:
        result = await session.execute(select(func.count()).select_from(Device))
        if result.scalar() > 0:
            logger.info("Database already has data, skipping seed")
            return
    
    # Create fake devices
    fake_devices = [
        ("esp32-tomato", "Tomates du balcon", "test-user", "1.2.3", 30),
        ("esp32-basil", "Basilic cuisine", "test-user", "1.2.3", 15),
        ("esp32-fern", "Fougère salon", "test-user", "1.2.0", 7),
    ]
    
    device_count = 0
    reading_count = 0
    command_count = 0
    
    for device_id, name, owner, fw_version, days_old in fake_devices:
        await create_device(device_id, name, owner, fw_version)
        device_count += 1
        
        # Generate readings (last 24 hours, every 15 minutes)
        base_temp = random.uniform(18, 24)
        base_humidity = random.uniform(40, 70)
        base_luminosity = random.uniform(30, 80)
        
        async with get_session() as session:
            for i in range(96):  # 24h * 4 readings/hour
                ts = now - timedelta(minutes=15 * (95 - i))
                hour = ts.hour
                
                temp_variation = 3 * (1 - abs(hour - 14) / 14)
                if 6 <= hour <= 20:
                    lum_variation = 40 * (1 - abs(hour - 13) / 7)
                else:
                    lum_variation = -base_luminosity * 0.8
                
                reading = Reading(
                    id=str(uuid.uuid4()),
                    device_id=device_id,
                    ts=ts,
                    temperature_c=round(base_temp + temp_variation + random.uniform(-1, 1), 1),
                    humidity_pct=round(max(0, min(100, base_humidity + random.uniform(-5, 5))), 1),
                    luminosity_pct=round(max(0, min(100, base_luminosity + lum_variation + random.uniform(-5, 5))), 1),
                )
                session.add(reading)
                reading_count += 1
    
    # Create sample commands
    sample_commands = [
        ("esp32-tomato", "pump_water", "done", 6, 5000, 50),
        ("esp32-tomato", "force_reading", "done", 2, None, None),
        ("esp32-basil", "pump_water", "pending", 0, 3000, 30),
    ]
    
    async with get_session() as session:
        for device_id, cmd_type, status, hours_ago, duration, amount in sample_commands:
            command = Command(
                id=str(uuid.uuid4()),
                device_id=device_id,
                type=cmd_type,
                status=status,
                created_at=now - timedelta(hours=hours_ago),
                updated_at=now - timedelta(hours=hours_ago) + timedelta(minutes=1) if status == "done" else now - timedelta(hours=hours_ago),
                duration_ms=duration,
                amount_ml=amount,
                requested_by="test-user",
            )
            session.add(command)
            command_count += 1
    
    # Set default firmware
    await set_firmware("1.0.0", url=None)
    
    print(f"✓ Seeded {device_count} devices")
    print(f"✓ Seeded {reading_count} readings")
    print(f"✓ Seeded {command_count} commands")
