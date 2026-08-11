from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.maintenance import (
    MaintenanceCreate,
    MaintenanceUpdate,
    MaintenanceOut,
)

from app.crud.maintenance import (
    create_maintenance,
    get_maintenances,
    get_maintenance,
    update_maintenance,
    delete_maintenance,
)

router = APIRouter(
    prefix="/maintenance",
    tags=["Maintenance"]
)


@router.post("/", response_model=MaintenanceOut)
def create_new_maintenance(
    maintenance: MaintenanceCreate,
    db: Session = Depends(get_db),
):
    return create_maintenance(db, maintenance)


@router.get("/", response_model=list[MaintenanceOut])
def read_maintenances(
    db: Session = Depends(get_db),
):
    return get_maintenances(db)


@router.get("/{maintenance_id}", response_model=MaintenanceOut)
def read_maintenance(
    maintenance_id: UUID,
    db: Session = Depends(get_db),
):
    maintenance = get_maintenance(db, maintenance_id)

    if not maintenance:
        raise HTTPException(
            status_code=404,
            detail="Maintenance record not found"
        )

    return maintenance


@router.put("/{maintenance_id}", response_model=MaintenanceOut)
def update_existing_maintenance(
    maintenance_id: UUID,
    maintenance: MaintenanceUpdate,
    db: Session = Depends(get_db),
):
    updated = update_maintenance(
        db,
        maintenance_id,
        maintenance
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Maintenance record not found"
        )

    return updated


@router.delete("/{maintenance_id}")
def delete_existing_maintenance(
    maintenance_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_maintenance(
        db,
        maintenance_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Maintenance record not found"
        )

    return {
        "message": "Maintenance record deleted successfully"
    }