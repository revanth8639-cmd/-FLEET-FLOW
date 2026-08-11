import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from app.database import Base


class VehicleMaintenance(Base):
    __tablename__ = "vehicle_maintenance"

    maintenance_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    vehicle_id = Column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.vehicle_id"),
        nullable=False
    )

    service_type = Column(
        String,
        nullable=False
    )

    description = Column(
        String,
        nullable=True
    )

    service_date = Column(
        DateTime,
        default=datetime.utcnow
    )

    next_service_date = Column(
        DateTime,
        nullable=True
    )

    cost = Column(
        Float,
        nullable=True
    )

    status = Column(
        String,
        default="Pending"
    )