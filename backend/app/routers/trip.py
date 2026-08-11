from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.trip import (
    TripCreate,
    TripUpdate,
    TripOut,
)
from app.crud.trip import (
    create_trip,
    get_trips,
    get_trip,
    update_trip,
    delete_trip,
)
from app.utils.routing import build_route

router = APIRouter(
    prefix="/trips",
    tags=["Trips"]
)


@router.post("/", response_model=TripOut)
def create_new_trip(
    trip: TripCreate,
    db: Session = Depends(get_db),
):
    return create_trip(db, trip)


@router.get("/", response_model=list[TripOut])
def read_trips(db: Session = Depends(get_db)):
    return get_trips(db)


@router.get("/{trip_id}/route")
def read_trip_route(
    trip_id: UUID,
    route_type: str = "Fastest Route",
    db: Session = Depends(get_db),
):
    trip = get_trip(db, trip_id)
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    try:
        return build_route(trip.start_location, trip.end_location, route_type)
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


@router.get("/{trip_id}", response_model=TripOut)
def read_trip(
    trip_id: UUID,
    db: Session = Depends(get_db),
):
    trip = get_trip(db, trip_id)

    if not trip:
        raise HTTPException(
            status_code=404,
            detail="Trip not found"
        )

    return trip


@router.put("/{trip_id}", response_model=TripOut)
def update_existing_trip(
    trip_id: UUID,
    trip: TripUpdate,
    db: Session = Depends(get_db),
):
    updated = update_trip(db, trip_id, trip)

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Trip not found"
        )

    return updated


@router.delete("/{trip_id}")
def delete_existing_trip(
    trip_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_trip(db, trip_id)

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Trip not found"
        )

    return {
        "message": "Trip deleted successfully"
    }
