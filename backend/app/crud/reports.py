from sqlalchemy.orm import Session

from app.models.vehicle import Vehicle
from app.models.driver import Driver
from app.models.shipment import Shipment
from app.models.trip import Trip
from app.models.fuel_record import FuelRecord
from app.models.maintenance import VehicleMaintenance
from app.models.notification import Notification
from app.models.attendance import Attendance


def get_reports_summary(db: Session):

    return {
        "total_vehicles": db.query(Vehicle).count(),

        "total_drivers": db.query(Driver).count(),

        "total_shipments": db.query(Shipment).count(),

        "total_trips": db.query(Trip).count(),

        "total_fuel_records": db.query(FuelRecord).count(),

        "total_maintenance": db.query(VehicleMaintenance).count(),

        "total_notifications": db.query(Notification).count(),

        "total_attendance": db.query(Attendance).count(),
    }


def get_shipment_report(db: Session):

    return {
        "total_shipments": db.query(Shipment).count()
    }


def get_trip_report(db: Session):

    return {
        "total_trips": db.query(Trip).count()
    }


def get_vehicle_report(db: Session):

    return {
        "total_vehicles": db.query(Vehicle).count()
    }


def get_fuel_report(db: Session):

    return {
        "total_fuel_records": db.query(FuelRecord).count()
    }


def get_maintenance_report(db: Session):

    return {
        "total_maintenance": db.query(VehicleMaintenance).count()
    }