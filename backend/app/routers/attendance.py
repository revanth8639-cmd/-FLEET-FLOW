from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.attendance import (
    AttendanceCreate,
    AttendanceUpdate,
    AttendanceOut,
)

from app.crud.attendance import (
    create_attendance,
    get_attendances,
    get_attendance,
    update_attendance,
    delete_attendance,
)

router = APIRouter(
    prefix="/attendance",
    tags=["Attendance"]
)


@router.post("/", response_model=AttendanceOut)
def create_new_attendance(
    attendance: AttendanceCreate,
    db: Session = Depends(get_db),
):
    return create_attendance(db, attendance)


@router.get("/", response_model=list[AttendanceOut])
def read_attendances(
    db: Session = Depends(get_db),
):
    return get_attendances(db)


@router.get("/{attendance_id}", response_model=AttendanceOut)
def read_attendance(
    attendance_id: UUID,
    db: Session = Depends(get_db),
):
    attendance = get_attendance(
        db,
        attendance_id
    )

    if not attendance:
        raise HTTPException(
            status_code=404,
            detail="Attendance record not found"
        )

    return attendance


@router.put("/{attendance_id}", response_model=AttendanceOut)
def update_existing_attendance(
    attendance_id: UUID,
    attendance: AttendanceUpdate,
    db: Session = Depends(get_db),
):
    updated = update_attendance(
        db,
        attendance_id,
        attendance
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Attendance record not found"
        )

    return updated


@router.delete("/{attendance_id}")
def delete_existing_attendance(
    attendance_id: UUID,
    db: Session = Depends(get_db),
):
    deleted = delete_attendance(
        db,
        attendance_id
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Attendance record not found"
        )

    return {
        "message": "Attendance deleted successfully"
    }