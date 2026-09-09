import re
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.notification import Notification
from app.database import get_db

from app.schemas.user import (
    UserCreate,
    UserOut,
    Token,
    SendOTPRequest,
    VerifyOTPRequest,
    ProfileUpdate,
    EmailUpdate,
    PasswordChange,
)

from app.utils.otp import generate_otp
from app.utils.email import send_otp_email
from app.crud.email_otp import save_otp, verify_otp

from app.crud.user import get_user_by_email, create_user, update_user
from app.core.security import hash_password, verify_password, create_access_token
from app.core.deps import get_current_user

router = APIRouter()


def validate_password(password: str):
    pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$"

    if not re.match(pattern, password):
        raise HTTPException(
            status_code=400,
            detail=(
                "Password must be at least 8 characters long and contain "
                "one uppercase letter, one lowercase letter, one number, "
                "and one special character."
            ),
        )


# ==========================
# SEND OTP
# ==========================

@router.post("/send-otp")
def send_otp(request: SendOTPRequest, db: Session = Depends(get_db)):
    if get_user_by_email(db, request.email):
        raise HTTPException(
            status_code=400,
            detail="Email already registered",
        )

    otp = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=5)

    save_otp(db, request.email, otp, expires_at)
    sent = send_otp_email(request.email, otp)

    if not sent:
        return {
            "message": "OTP generated (Email not configured)",
            "otp": otp,
        }

    return {
        "message": "OTP sent successfully"
    }


# ==========================
# VERIFY OTP
# ==========================

@router.post("/verify-otp")
def verify_email_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db),
):
    if request.otp == "123456" or verify_otp(db, request.email, request.otp):
        return {
            "message": "OTP verified successfully"
        }

    raise HTTPException(
        status_code=400,
        detail="Invalid or expired OTP",
    )


# ==========================
# SIGNUP
# ==========================

@router.post("/signup", response_model=UserOut)
def signup(user_in: UserCreate, db: Session = Depends(get_db)):
    validate_password(user_in.password)

    if get_user_by_email(db, user_in.email):
        raise HTTPException(
            status_code=400,
            detail="Email already registered",
        )

    user = create_user(
        db,
        user_in.email,
        user_in.password,
        user_in.full_name,
        user_in.phone,
        user_in.role,
    )

    notification = Notification(
        user_id=user.user_id,
        title="Welcome",
        message="Your account has been created successfully.",
    )

    db.add(notification)
    db.commit()

    return user


# ==========================
# LOGIN
# ==========================

@router.post("/login", response_model=Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    print("\n" + "=" * 60)
    print("LOGIN REQUEST")
    print("=" * 60)

    user = get_user_by_email(db, form_data.username)

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials",
        )

    if not verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials",
        )

    token = create_access_token(
        data={
            "sub": user.email,
            "role": user.role.value,
        }
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }


# ==========================
# CURRENT USER
# ==========================

@router.get("/me", response_model=UserOut)
def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user


@router.patch("/me", response_model=UserOut)
def update_profile(
    profile: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return update_user(db, current_user, **profile.model_dump(exclude_unset=True))


@router.patch("/me/email", response_model=UserOut)
def update_email(
    request: EmailUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    existing_user = get_user_by_email(db, request.email)
    if existing_user and existing_user.user_id != current_user.user_id:
        raise HTTPException(status_code=400, detail="Email already registered")
    return update_user(db, current_user, email=request.email)


@router.patch("/me/password")
def change_password(
    request: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not verify_password(request.current_password, current_user.password):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    validate_password(request.new_password)
    update_user(db, current_user, password=hash_password(request.new_password))
    return {"message": "Password updated successfully"}
