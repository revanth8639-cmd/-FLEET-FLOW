"""Seed initial data into the database if not present."""

import json
import uuid
from pathlib import Path
from datetime import datetime, date
from app.database import SessionLocal
from app.models.user import User, RoleEnum
from app.models.vehicle import Vehicle
from app.models.driver import Driver
from app.models.shipment import Shipment
from app.models.trip import Trip
from app.models.attendance import Attendance
from app.models.maintenance import VehicleMaintenance
from app.models.fuel_record import FuelRecord
from app.models.leave_request import LeaveRequest
from app.models.gps_tracking import GPSTracking
from app.models.notification import Notification


def parse_dt(val):
    if not val:
        return None
    try:
        return datetime.fromisoformat(val)
    except Exception:
        return None


def parse_date(val):
    if not val:
        return None
    try:
        return date.fromisoformat(val)
    except Exception:
        return None


def parse_uuid(val):
    if not val:
        return None
    if isinstance(val, uuid.UUID):
        return val
    return uuid.UUID(str(val))


def load_seed_data():
    seed_path = Path(__file__).parent / "seed_data.json"
    if seed_path.exists():
        try:
            with open(seed_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading seed_data.json: {e}")
    return {}


def seed_database(db=None):
    close_session = False
    if db is None:
        db = SessionLocal()
        close_session = True

    try:
        data = load_seed_data()

        # 1. Seed Users
        if db.query(User).first() is None and "users" in data:
            for r in data["users"]:
                role_val = r.get("role")
                try:
                    role_enum = RoleEnum(role_val) if role_val else RoleEnum.FleetManager
                except Exception:
                    role_enum = RoleEnum.FleetManager

                u = User(
                    user_id=parse_uuid(r.get("user_id")),
                    full_name=r.get("full_name"),
                    email=r.get("email"),
                    password=r.get("password"),
                    phone=r.get("phone"),
                    address=r.get("address"),
                    role=role_enum,
                    email_verified=r.get("email_verified", False),
                    created_at=parse_dt(r.get("created_at")),
                    updated_at=parse_dt(r.get("updated_at")),
                )
                db.add(u)
            db.commit()

        # 2. Seed Vehicles
        if db.query(Vehicle).first() is None and "vehicles" in data:
            for r in data["vehicles"]:
                v = Vehicle(
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    registration_number=r.get("registration_number"),
                    vehicle_type=r.get("vehicle_type"),
                    capacity=r.get("capacity"),
                    fuel_type=r.get("fuel_type"),
                    status=r.get("status"),
                    created_at=parse_dt(r.get("created_at")),
                )
                db.add(v)
            db.commit()

        # 3. Seed Drivers
        if db.query(Driver).first() is None and "drivers" in data:
            for r in data["drivers"]:
                d = Driver(
                    driver_id=parse_uuid(r.get("driver_id")),
                    user_id=parse_uuid(r.get("user_id")),
                    name=r.get("name"),
                    phone=r.get("phone"),
                    license_number=r.get("license_number"),
                    status=r.get("status"),
                    created_at=parse_dt(r.get("created_at")),
                )
                db.add(d)
            db.commit()

        # 4. Seed Shipments
        if db.query(Shipment).first() is None and "shipments" in data:
            for r in data["shipments"]:
                s = Shipment(
                    shipment_id=parse_uuid(r.get("shipment_id")),
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    driver_id=parse_uuid(r.get("driver_id")),
                    tracking_number=r.get("tracking_number"),
                    source=r.get("source"),
                    destination=r.get("destination"),
                    status=r.get("status"),
                    eta=str(r.get("eta")) if r.get("eta") else None,
                    created_at=parse_dt(r.get("created_at")),
                )
                db.add(s)
            db.commit()

        # 5. Seed Trips
        if db.query(Trip).first() is None and "trips" in data:
            for r in data["trips"]:
                t = Trip(
                    trip_id=parse_uuid(r.get("trip_id")),
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    driver_id=parse_uuid(r.get("driver_id")),
                    shipment_id=parse_uuid(r.get("shipment_id")),
                    start_location=r.get("start_location"),
                    end_location=r.get("end_location"),
                    start_time=parse_dt(r.get("start_time")),
                    end_time=parse_dt(r.get("end_time")),
                    status=r.get("status"),
                )
                db.add(t)
            db.commit()

        # 6. Seed Attendance
        if db.query(Attendance).first() is None and "attendance" in data:
            for r in data["attendance"]:
                a = Attendance(
                    attendance_id=parse_uuid(r.get("attendance_id")),
                    driver_id=parse_uuid(r.get("driver_id")),
                    check_in=parse_dt(r.get("check_in")),
                    check_out=parse_dt(r.get("check_out")),
                    status=r.get("status"),
                )
                db.add(a)
            db.commit()

        # 7. Seed Vehicle Maintenance
        if db.query(VehicleMaintenance).first() is None and "vehicle_maintenance" in data:
            for r in data["vehicle_maintenance"]:
                vm = VehicleMaintenance(
                    maintenance_id=parse_uuid(r.get("maintenance_id")),
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    service_type=r.get("service_type"),
                    description=r.get("description"),
                    service_date=parse_dt(r.get("service_date")),
                    next_service_date=parse_dt(r.get("next_service_date")),
                    cost=r.get("cost"),
                    status=r.get("status"),
                )
                db.add(vm)
            db.commit()

        # 8. Seed Fuel Records
        if db.query(FuelRecord).first() is None and "fuel_records" in data:
            for r in data["fuel_records"]:
                fr = FuelRecord(
                    fuel_id=parse_uuid(r.get("fuel_id")),
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    fuel_amount=r.get("fuel_amount"),
                    fuel_cost=r.get("fuel_cost"),
                    fuel_station=r.get("fuel_station"),
                    filled_by=r.get("filled_by"),
                    fuel_date=parse_dt(r.get("fuel_date")),
                )
                db.add(fr)
            db.commit()

        # 9. Seed Leave Requests
        if db.query(LeaveRequest).first() is None and "leave_requests" in data:
            for r in data["leave_requests"]:
                lr = LeaveRequest(
                    leave_id=parse_uuid(r.get("leave_id")),
                    driver_id=parse_uuid(r.get("driver_id")),
                    leave_date=parse_date(r.get("leave_date")),
                    reason=r.get("reason"),
                    status=r.get("status"),
                    reviewed_by=parse_uuid(r.get("reviewed_by")),
                    created_at=parse_dt(r.get("created_at")),
                )
                db.add(lr)
            db.commit()

        # 10. Seed GPS Tracking
        if db.query(GPSTracking).first() is None and "gps_tracking" in data:
            for r in data["gps_tracking"]:
                gt = GPSTracking(
                    tracking_id=parse_uuid(r.get("tracking_id")),
                    vehicle_id=parse_uuid(r.get("vehicle_id")),
                    latitude=r.get("latitude"),
                    longitude=r.get("longitude"),
                    speed=r.get("speed"),
                    timestamp=parse_dt(r.get("timestamp")),
                )
                db.add(gt)
            db.commit()

        # 11. Seed Notifications
        if db.query(Notification).first() is None and "notifications" in data:
            for r in data["notifications"]:
                n = Notification(
                    notification_id=parse_uuid(r.get("notification_id")),
                    user_id=parse_uuid(r.get("user_id")),
                    title=r.get("title"),
                    message=r.get("message"),
                    is_read=r.get("is_read", False),
                    created_at=parse_dt(r.get("created_at")),
                )
                db.add(n)
            db.commit()

    except Exception as exc:
        db.rollback()
        print(f"Database seeding error/deferred: {exc}")
    finally:
        if close_session:
            db.close()


def seed_default_users():
    seed_database()

