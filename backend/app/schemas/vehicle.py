from uuid import UUID
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class VehicleCreate(BaseModel):
    registration_number: str
    vehicle_type: str
    capacity: str
    fuel_type: str
    status: str = "Available"


class VehicleUpdate(BaseModel):
    registration_number: Optional[str] = None
    vehicle_type: Optional[str] = None
    capacity: Optional[str] = None
    fuel_type: Optional[str] = None
    status: Optional[str] = None


class VehicleOut(BaseModel):
    vehicle_id: UUID
    registration_number: str
    vehicle_type: str
    capacity: str
    fuel_type: str
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)