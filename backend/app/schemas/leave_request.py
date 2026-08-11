from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel, ConfigDict

class LeaveCreate(BaseModel):
    leave_date: date
    reason: str | None = None

class LeaveDecision(BaseModel):
    status: str

class LeaveOut(BaseModel):
    leave_id: UUID
    driver_id: UUID
    leave_date: date
    reason: str | None
    status: str
    reviewed_by: UUID | None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
