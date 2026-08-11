from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, ConfigDict


class GPSTrackingCreate(BaseModel):
    vehicle_id: UUID
    latitude: float
    longitude: float
    speed: float | None = None


class GPSTrackingOut(BaseModel):
    tracking_id: UUID
    vehicle_id: UUID
    latitude: float
    longitude: float
    speed: float | None
    timestamp: datetime

    model_config = ConfigDict(from_attributes=True)
    