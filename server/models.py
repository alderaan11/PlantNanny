"""
SQLAlchemy ORM Models for PlantNanny
"""
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy import (
    String, Integer, Float, DateTime, Boolean, Text, ForeignKey, Index
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
import uuid


class Base(DeclarativeBase):
    """Base class for all ORM models."""
    pass


class Device(Base):
    """Device model - represents an ESP32 PlantNanny device."""
    __tablename__ = "devices"

    device_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    owner_uid: Mapped[str] = mapped_column(String(128), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc)
    )
    last_seen: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    firmware_version: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    last_status: Mapped[Optional[str]] = mapped_column(String(32), default="unknown")

    # Relationships
    readings: Mapped[List["Reading"]] = relationship(
        "Reading", back_populates="device", cascade="all, delete-orphan"
    )
    commands: Mapped[List["Command"]] = relationship(
        "Command", back_populates="device", cascade="all, delete-orphan"
    )
    api_key: Mapped[Optional["DeviceApiKey"]] = relationship(
        "DeviceApiKey", back_populates="device", uselist=False, cascade="all, delete-orphan"
    )

    def to_dict(self) -> dict:
        """Convert to API response format."""
        return {
            "deviceId": self.device_id,
            "name": self.name,
            "ownerUid": self.owner_uid,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "lastSeen": self.last_seen.isoformat() if self.last_seen else None,
            "firmwareVersion": self.firmware_version,
            "lastStatus": self.last_status,
        }


class Reading(Base):
    """Sensor reading from a device."""
    __tablename__ = "readings"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    device_id: Mapped[str] = mapped_column(
        String(64), ForeignKey("devices.device_id", ondelete="CASCADE"), nullable=False
    )
    ts: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        index=True
    )
    temperature_c: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    humidity_pct: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    luminosity_pct: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    soil_moisture_pct: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    # Relationship
    device: Mapped["Device"] = relationship("Device", back_populates="readings")

    # Indexes for common queries
    __table_args__ = (
        Index("ix_readings_device_ts", "device_id", "ts"),
    )

    def to_dict(self) -> dict:
        """Convert to API response format."""
        return {
            "id": self.id,
            "deviceId": self.device_id,
            "ts": self.ts.isoformat() if self.ts else None,
            "temperatureC": self.temperature_c,
            "humidityPct": self.humidity_pct,
            "luminosityPct": self.luminosity_pct,
            "soilMoisturePct": self.soil_moisture_pct,
        }


class Command(Base):
    """Command sent to a device."""
    __tablename__ = "commands"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    device_id: Mapped[str] = mapped_column(
        String(64), ForeignKey("devices.device_id", ondelete="CASCADE"), nullable=False
    )
    type: Mapped[str] = mapped_column(String(32), nullable=False)
    status: Mapped[str] = mapped_column(String(32), default="pending", index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc)
    )
    duration_ms: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    amount_ml: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    requested_by: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    error_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Relationship
    device: Mapped["Device"] = relationship("Device", back_populates="commands")

    # Indexes
    __table_args__ = (
        Index("ix_commands_device_status", "device_id", "status"),
        Index("ix_commands_device_created", "device_id", "created_at"),
    )

    def to_dict(self) -> dict:
        """Convert to API response format."""
        return {
            "id": self.id,
            "deviceId": self.device_id,
            "type": self.type,
            "status": self.status,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "updatedAt": self.updated_at.isoformat() if self.updated_at else None,
            "durationMs": self.duration_ms,
            "amountMl": self.amount_ml,
            "requestedBy": self.requested_by,
            "errorMessage": self.error_message,
        }


class Firmware(Base):
    """Firmware version tracking."""
    __tablename__ = "firmware"

    version: Mapped[str] = mapped_column(String(32), primary_key=True)
    url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    filename: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    size: Mapped[int] = mapped_column(Integer, default=0)
    checksum: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    uploaded_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    is_latest: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    release_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    def to_dict(self) -> dict:
        """Convert to API response format."""
        return {
            "version": self.version,
            "url": self.url,
            "filename": self.filename,
            "size": self.size,
            "checksum": self.checksum,
            "uploadedAt": self.uploaded_at.isoformat() if self.uploaded_at else None,
            "isLatest": self.is_latest,
            "releaseNotes": self.release_notes,
        }


class DeviceApiKey(Base):
    """API keys for device authentication."""
    __tablename__ = "device_api_keys"

    api_key: Mapped[str] = mapped_column(String(128), primary_key=True)
    device_id: Mapped[str] = mapped_column(
        String(64), 
        ForeignKey("devices.device_id", ondelete="CASCADE"), 
        unique=True,
        nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
    last_used: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationship
    device: Mapped["Device"] = relationship("Device", back_populates="api_key")
