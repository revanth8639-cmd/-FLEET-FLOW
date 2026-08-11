from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.shipment import (
    ShipmentCreate,
    ShipmentUpdate,
    ShipmentOut,
)

from app.crud.shipment import (
    create_shipment,
    get_shipments,
    get_shipment,
    update_shipment,
    delete_shipment,
)


router = APIRouter(
    prefix="/shipments",
    tags=["Shipments"]
)


# Shipment status update schema
class ShipmentStatusUpdate(BaseModel):
    status: str


# Create Shipment
@router.post("/", response_model=ShipmentOut)
def create_new_shipment(
    shipment: ShipmentCreate,
    db: Session = Depends(get_db),
):
    return create_shipment(db, shipment)


# Get all shipments
@router.get("/", response_model=list[ShipmentOut])
def read_shipments(
    db: Session = Depends(get_db)
):
    return get_shipments(db)


# Get shipment by ID
@router.get("/{shipment_id}", response_model=ShipmentOut)
def read_shipment(
    shipment_id: UUID,
    db: Session = Depends(get_db),
):
    shipment = get_shipment(db, shipment_id)

    if not shipment:
        raise HTTPException(
            status_code=404,
            detail="Shipment not found"
        )

    return shipment


# Update complete shipment details
@router.put("/{shipment_id}", response_model=ShipmentOut)
def update_existing_shipment(
    shipment_id: UUID,
    shipment: ShipmentUpdate,
    db: Session = Depends(get_db),
):
    updated = update_shipment(
        db,
        shipment_id,
        shipment
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Shipment not found"
        )

    return updated


# Update only shipment status
@router.put("/{shipment_id}/status")
def update_shipment_status(
    shipment_id: UUID,
    data: ShipmentStatusUpdate,
    db: Session = Depends(get_db),
):
    shipment = get_shipment(
        db,
        shipment_id
    )

    if not shipment:
        raise HTTPException(
            status_code=404,
            detail="Shipment not found"
        )


    allowed_status = [
        "Created",
        "Assigned",
        "In Transit",
        "Delayed",
        "Delivered",
        "Cancelled"
    ]


    if data.status not in allowed_status:
        raise HTTPException(
            status_code=400,
            detail="Invalid shipment status"
        )


    shipment.status = data.status

    db.commit()
    db.refresh(shipment)


    return {
        "message": "Shipment status updated successfully",
        "shipment_id": str(shipment.shipment_id),
        "status": shipment.status
    }


# Delete shipment
@router.delete("/{shipment_id}")
def delete_existing_shipment(
    shipment_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_shipment(
        db,
        shipment_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Shipment not found"
        )

    return {
        "message": "Shipment deleted successfully"
    }