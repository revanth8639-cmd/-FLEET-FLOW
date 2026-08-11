import uuid
from datetime import datetime
from sqlalchemy import Column, Date, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class LeaveRequest(Base):
    __tablename__ = "leave_requests"
    leave_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    driver_id = Column(UUID(as_uuid=True), ForeignKey("drivers.driver_id"), nullable=False)
    leave_date = Column(Date, nullable=False)
    reason = Column(Text, nullable=True)
    status = Column(String, nullable=False, default="Pending")
    reviewed_by = Column(UUID(as_uuid=True), ForeignKey("users.user_id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
