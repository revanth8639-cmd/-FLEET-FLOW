from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.core.deps import get_current_user, require_roles
from app.schemas.driver import (
    DriverCreate,
    DriverUpdate,
    DriverOut,
)
from app.crud.driver import (
    create_driver,
    get_drivers,
    get_driver,
    update_driver,
    delete_driver,
)

router = APIRouter(
    prefix="/drivers",
    tags=["Drivers"]
)


@router.post("/", response_model=DriverOut)
def create_new_driver(
    driver: DriverCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_roles("Admin", "FleetManager")),
):
    return create_driver(db, driver)


@router.get("/", response_model=list[DriverOut])
def read_drivers(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_drivers(db)


@router.get("/{driver_id}", response_model=DriverOut)
def read_driver(
    driver_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    driver = get_driver(db, driver_id)

    if not driver:
        raise HTTPException(
            status_code=404,
            detail="Driver not found"
        )

    return driver


@router.put("/{driver_id}", response_model=DriverOut)
def update_existing_driver(
    driver_id: UUID,
    driver: DriverUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(require_roles("Admin", "FleetManager")),
):
    updated = update_driver(
        db,
        driver_id,
        driver,
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Driver not found"
        )

    return updated


@router.delete("/{driver_id}")
def delete_existing_driver(
    driver_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(require_roles("Admin", "FleetManager")),
):
    deleted = delete_driver(
        db,
        driver_id,
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Driver not found"
        )

    return {
        "message": "Driver deleted successfully"
    }
