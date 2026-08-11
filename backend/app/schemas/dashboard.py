from pydantic import BaseModel


class DashboardSummary(BaseModel):
    total_vehicles: int
    total_drivers: int
    total_shipments: int
    total_trips: int
    total_maintenance: int
    total_fuel_records: int
    total_notifications: int
    total_attendance: int