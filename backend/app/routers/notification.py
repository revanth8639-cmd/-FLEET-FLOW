from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.notification import (
    NotificationCreate,
    NotificationUpdate,
    NotificationOut,
)

from app.crud.notification import (
    create_notification,
    get_notifications,
    get_notification,
    update_notification,
    delete_notification,
)

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"]
)


@router.post("/", response_model=NotificationOut)
def create_new_notification(
    notification: NotificationCreate,
    db: Session = Depends(get_db),
):
    return create_notification(db, notification)


@router.get("/", response_model=list[NotificationOut])
def read_notifications(
    db: Session = Depends(get_db),
):
    return get_notifications(db)


@router.get("/{notification_id}", response_model=NotificationOut)
def read_notification(
    notification_id: UUID,
    db: Session = Depends(get_db),
):
    notification = get_notification(
        db,
        notification_id
    )

    if not notification:
        raise HTTPException(
            status_code=404,
            detail="Notification not found"
        )

    return notification


@router.put("/{notification_id}", response_model=NotificationOut)
def update_existing_notification(
    notification_id: UUID,
    notification: NotificationUpdate,
    db: Session = Depends(get_db),
):
    updated = update_notification(
        db,
        notification_id,
        notification
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Notification not found"
        )

    return updated


@router.delete("/{notification_id}")
def delete_existing_notification(
    notification_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_notification(
        db,
        notification_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Notification not found"
        )

    return {
        "message": "Notification deleted successfully"
    }