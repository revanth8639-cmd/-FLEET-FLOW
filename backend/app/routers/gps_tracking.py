from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.gps_tracking import (
    GPSTrackingCreate,
    GPSTrackingOut,
)

from app.crud.gps_tracking import (
    create_gps_tracking,
    get_latest_locations,
    get_latest_location,
    get_tracking_history,
)


router = APIRouter(
    prefix="/gps",
    tags=["GPS Tracking"]
)


# Add GPS location
@router.post("/", response_model=GPSTrackingOut)
def add_gps_location(
    gps_data: GPSTrackingCreate,
    db: Session = Depends(get_db),
):
    return create_gps_tracking(
        db,
        gps_data
    )


# Get latest vehicle location
@router.get("/{vehicle_id}", response_model=GPSTrackingOut)
def read_latest_location(
    vehicle_id: UUID,
    db: Session = Depends(get_db),
):
    location = get_latest_location(
        db,
        vehicle_id
    )

    if not location:
        raise HTTPException(
            status_code=404,
            detail="GPS location not found"
        )

    return location


# Get vehicle tracking history
@router.get(
    "/history/{vehicle_id}",
    response_model=list[GPSTrackingOut]
)
def read_tracking_history(
    vehicle_id: UUID,
    db: Session = Depends(get_db),
):
    return get_tracking_history(
        db,
        vehicle_id
    )


@router.get("/", response_model=list[GPSTrackingOut])
def read_latest_locations(db: Session = Depends(get_db)):
    return get_latest_locations(db)
