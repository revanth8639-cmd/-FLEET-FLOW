from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.fuel_record import (
    FuelRecordCreate,
    FuelRecordUpdate,
    FuelRecordOut,
)

from app.crud.fuel_record import (
    create_fuel_record,
    get_fuel_records,
    get_fuel_record,
    update_fuel_record,
    delete_fuel_record,
)

router = APIRouter(
    prefix="/fuel",
    tags=["Fuel Records"]
)


@router.post("/", response_model=FuelRecordOut)
def create_new_fuel_record(
    fuel: FuelRecordCreate,
    db: Session = Depends(get_db),
):
    return create_fuel_record(db, fuel)


@router.get("/", response_model=list[FuelRecordOut])
def read_fuel_records(
    db: Session = Depends(get_db),
):
    return get_fuel_records(db)


@router.get("/{fuel_id}", response_model=FuelRecordOut)
def read_fuel_record(
    fuel_id: UUID,
    db: Session = Depends(get_db),
):
    fuel = get_fuel_record(db, fuel_id)

    if not fuel:
        raise HTTPException(
            status_code=404,
            detail="Fuel record not found"
        )

    return fuel


@router.put("/{fuel_id}", response_model=FuelRecordOut)
def update_existing_fuel_record(
    fuel_id: UUID,
    fuel: FuelRecordUpdate,
    db: Session = Depends(get_db),
):
    updated = update_fuel_record(
        db,
        fuel_id,
        fuel
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Fuel record not found"
        )

    return updated


@router.delete("/{fuel_id}")
def delete_existing_fuel_record(
    fuel_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_fuel_record(
        db,
        fuel_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Fuel record not found"
        )

    return {
        "message": "Fuel record deleted successfully"
    }