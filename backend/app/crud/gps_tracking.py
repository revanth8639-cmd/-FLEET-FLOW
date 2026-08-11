from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.gps_tracking import GPSTracking
from app.schemas.gps_tracking import GPSTrackingCreate


def create_gps_tracking(
    db: Session,
    gps_data: GPSTrackingCreate
):
    gps = GPSTracking(
        **gps_data.model_dump()
    )

    db.add(gps)
    db.commit()
    db.refresh(gps)

    return gps


def get_latest_location(
    db: Session,
    vehicle_id
):
    return (
        db.query(GPSTracking)
        .filter(
            GPSTracking.vehicle_id == vehicle_id
        )
        .order_by(
            GPSTracking.timestamp.desc()
        )
        .first()
    )


def get_tracking_history(
    db: Session,
    vehicle_id
):
    return (
        db.query(GPSTracking)
        .filter(
            GPSTracking.vehicle_id == vehicle_id
        )
        .order_by(
            GPSTracking.timestamp.desc()
        )
        .all()
    )


def get_latest_locations(db: Session):
    """Return one current location per vehicle, newest first."""
    latest_per_vehicle = (
        db.query(
            GPSTracking.vehicle_id.label("vehicle_id"),
            func.max(GPSTracking.timestamp).label("latest_timestamp"),
        )
        .group_by(GPSTracking.vehicle_id)
        .subquery()
    )
    return (
        db.query(GPSTracking)
        .join(
            latest_per_vehicle,
            (GPSTracking.vehicle_id == latest_per_vehicle.c.vehicle_id)
            & (GPSTracking.timestamp == latest_per_vehicle.c.latest_timestamp),
        )
        .order_by(GPSTracking.timestamp.desc())
        .all()
    )
