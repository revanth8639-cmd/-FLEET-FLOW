from uuid import UUID
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class FuelRecordCreate(BaseModel):
    vehicle_id: UUID
    fuel_amount: float
    fuel_cost: float
    fuel_station: str
    filled_by: str | None = None


class FuelRecordUpdate(BaseModel):
    fuel_amount: float | None = None
    fuel_cost: float | None = None
    fuel_station: str | None = None
    filled_by: str | None = None


class FuelRecordOut(BaseModel):
    fuel_id: UUID
    vehicle_id: UUID
    fuel_amount: float
    fuel_cost: float
    fuel_station: str
    filled_by: str | None
    fuel_date: datetime

    model_config = ConfigDict(from_attributes=True)