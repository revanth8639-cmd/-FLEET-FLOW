import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from app.database import Base


class Attendance(Base):
    __tablename__ = "attendance"

    attendance_id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    driver_id = Column(
        UUID(as_uuid=True),
        ForeignKey("drivers.driver_id"),
        nullable=False
    )

    check_in = Column(
        DateTime,
        default=datetime.utcnow
    )

    check_out = Column(
        DateTime,
        nullable=True
    )

    status = Column(
        String,
        nullable=False
    )