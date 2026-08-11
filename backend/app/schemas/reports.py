from pydantic import BaseModel


class ShipmentReport(BaseModel):
    total_shipments: int


class TripReport(BaseModel):
    total_trips: int


class VehicleReport(BaseModel):
    total_vehicles: int


class FuelReport(BaseModel):
    total_fuel_records: int


class MaintenanceReport(BaseModel):
    total_maintenance: int


class ReportsSummary(BaseModel):
    total_vehicles: int
    total_drivers: int
    total_shipments: int
    total_trips: int
    total_fuel_records: int
    total_maintenance: int
    total_notifications: int
    total_attendance: int