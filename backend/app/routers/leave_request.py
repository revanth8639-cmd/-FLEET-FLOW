from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.driver import Driver
from app.models.leave_request import LeaveRequest
from app.schemas.leave_request import LeaveCreate, LeaveDecision, LeaveOut
from app.core.deps import get_current_user, require_roles

router = APIRouter(prefix="/leave-requests", tags=["Leave Requests"])

@router.post("/", response_model=LeaveOut)
def request_leave(data: LeaveCreate, db: Session = Depends(get_db), current_user=Depends(require_roles("Driver"))):
    driver = db.query(Driver).filter(Driver.user_id == current_user.user_id).first()
    if not driver:
        # Driver sign-up creates a User first; create the related operational
        # profile on demand so a new driver can immediately request leave.
        driver = Driver(
            user_id=current_user.user_id,
            name=current_user.full_name,
            phone=current_user.phone or "Not provided",
            license_number="Pending verification",
            status="Available",
        )
        db.add(driver)
        db.flush()
    request = LeaveRequest(driver_id=driver.driver_id, **data.model_dump())
    db.add(request); db.commit(); db.refresh(request)
    return request

@router.get("/", response_model=list[LeaveOut])
def list_leave_requests(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if current_user.role.value == "Driver":
        driver = db.query(Driver).filter(Driver.user_id == current_user.user_id).first()
        return [] if not driver else db.query(LeaveRequest).filter(LeaveRequest.driver_id == driver.driver_id).order_by(LeaveRequest.leave_date.desc()).all()
    return db.query(LeaveRequest).order_by(LeaveRequest.leave_date.desc()).all()

@router.patch("/{leave_id}", response_model=LeaveOut)
def decide_leave(leave_id: str, data: LeaveDecision, db: Session = Depends(get_db), current_user=Depends(require_roles("Admin", "FleetManager"))):
    if data.status not in {"Approved", "Rejected"}: raise HTTPException(400, "Status must be Approved or Rejected")
    request = db.query(LeaveRequest).filter(LeaveRequest.leave_id == leave_id).first()
    if not request: raise HTTPException(404, "Leave request not found")
    request.status, request.reviewed_by = data.status, current_user.user_id
    db.commit(); db.refresh(request)
    return request
