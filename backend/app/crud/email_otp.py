from datetime import datetime
from sqlalchemy.orm import Session
from app.models.email_otp import EmailOTP


def save_otp(db: Session, email: str, otp: str, expires_at: datetime):
    record = db.query(EmailOTP).filter(EmailOTP.email == email).first()

    if record:
        record.otp = otp
        record.expires_at = expires_at
    else:
        record = EmailOTP(
            email=email,
            otp=otp,
            expires_at=expires_at
        )
        db.add(record)

    db.commit()


def verify_otp(db: Session, email: str, otp: str):
    record = db.query(EmailOTP).filter(EmailOTP.email == email).first()

    if not record:
        return False

    if record.otp != otp:
        return False

    if datetime.utcnow() > record.expires_at:
        return False

    db.delete(record)
    db.commit()

    return True