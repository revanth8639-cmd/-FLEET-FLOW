from datetime import datetime

from sqlalchemy import Column, String, DateTime

from app.database import Base


class EmailOTP(Base):
    __tablename__ = "email_otps"

    email = Column(String(100), primary_key=True)
    otp = Column(String(6), nullable=False)
    expires_at = Column(DateTime, nullable=False)