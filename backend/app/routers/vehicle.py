from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.core.deps import get_current_user, require_roles

from app.schemas.vehicle import (
    VehicleCreate,
    VehicleUpdate,
    VehicleOut,
)

from app.crud.vehicle import (
    create_vehicle,
    get_vehicles,
    get_vehicle,
    update_vehicle,
    delete_vehicle,
)


router = APIRouter(
    prefix="/vehicles",
    tags=["Vehicles"]
)


# CREATE VEHICLE
# Admin + Fleet Manager only
@router.post("/", response_model=VehicleOut)
def create_new_vehicle(
    vehicle: VehicleCreate,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_roles("Admin", "FleetManager")
    ),
):
    return create_vehicle(db, vehicle)


# READ ALL VEHICLES
# All authenticated users
@router.get("/", response_model=list[VehicleOut])
def read_vehicles(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return get_vehicles(db)


# READ ONE VEHICLE
# All authenticated users
@router.get("/{vehicle_id}", response_model=VehicleOut)
def read_vehicle(
    vehicle_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    vehicle = get_vehicle(db, vehicle_id)

    if not vehicle:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    return vehicle


# UPDATE VEHICLE
# Admin + Fleet Manager only
@router.put("/{vehicle_id}", response_model=VehicleOut)
def update_existing_vehicle(
    vehicle_id: UUID,
    vehicle: VehicleUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_roles("Admin", "FleetManager")
    ),
):
    updated = update_vehicle(
        db,
        vehicle_id,
        vehicle
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    return updated


# DELETE VEHICLE
# Admin + Fleet Manager only
@router.delete("/{vehicle_id}")
def delete_existing_vehicle(
    vehicle_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_roles("Admin", "FleetManager")
    ),
):
    deleted = delete_vehicle(
        db,
        vehicle_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    return {
        "message": "Vehicle deleted successfully"
    }