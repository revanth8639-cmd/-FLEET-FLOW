from uuid import UUID
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class NotificationCreate(BaseModel):
    user_id: UUID
    title: str
    message: str


class NotificationUpdate(BaseModel):
    title: str | None = None
    message: str | None = None
    is_read: bool | None = None


class NotificationOut(BaseModel):
    notification_id: UUID
    user_id: UUID
    title: str
    message: str
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)