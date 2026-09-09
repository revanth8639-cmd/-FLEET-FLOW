import smtplib
from email.mime.text import MIMEText

from app.core.config import MAIL_USERNAME, MAIL_PASSWORD, MAIL_FROM


def send_otp_email(receiver_email: str, otp: str) -> bool:
    if not MAIL_USERNAME or not MAIL_PASSWORD:
        print(f"[OTP DEV MODE] Email service not configured. Generated OTP for {receiver_email}: {otp}")
        return False

    subject = "FleetFlow - Email Verification OTP"

    body = f"""
Hello,

Your FleetFlow verification OTP is: {otp}

This OTP is valid for 5 minutes.

Do not share this OTP with anyone.

Regards,
FleetFlow Team
"""

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = MAIL_FROM or MAIL_USERNAME
    msg["To"] = receiver_email

    server = None
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587, timeout=5)
        server.starttls()
        server.login(MAIL_USERNAME, MAIL_PASSWORD)
        server.send_message(msg)
        print(f"Email sent successfully to {receiver_email}")
        return True
    except Exception as e:
        print("EMAIL ERROR:", e)
        return False
    finally:
        if server:
            try:
                server.quit()
            except Exception:
                pass