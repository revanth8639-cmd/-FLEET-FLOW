from uuid import UUID
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class ShipmentCreate(BaseModel):
    vehicle_id: Optional[UUID] = None
    driver_id: Optional[UUID] = None
    tracking_number: str
    source: str
    destination: str
    status: str = "Created"
    eta: Optional[str] = None


class ShipmentUpdate(BaseModel):
    vehicle_id: Optional[UUID] = None
    driver_id: Optional[UUID] = None
    tracking_number: Optional[str] = None
    source: Optional[str] = None
    destination: Optional[str] = None
    status: Optional[str] = None
    eta: Optional[str] = None


class ShipmentOut(BaseModel):
    shipment_id: UUID
    vehicle_id: Optional[UUID]
    driver_id: Optional[UUID]
    tracking_number: str
    source: str
    destination: str
    status: str
    eta: Optional[str]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)