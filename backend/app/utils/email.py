import smtplib
from email.mime.text import MIMEText

from app.core.config import MAIL_USERNAME, MAIL_PASSWORD, MAIL_FROM


def send_otp_email(receiver_email: str, otp: str):
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
    msg["From"] = MAIL_FROM
    msg["To"] = receiver_email

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()

    print("MAIL_USERNAME =", repr(MAIL_USERNAME))
    print("MAIL_FROM =", repr(MAIL_FROM))
    print("MAIL_PASSWORD length =", len(MAIL_PASSWORD) if MAIL_PASSWORD else 0)

    try:
        server.login(MAIL_USERNAME, MAIL_PASSWORD)
        print("Login successful")

        server.send_message(msg)
        print("Email sent successfully")

    except Exception as e:
        print("EMAIL ERROR:", e)

    finally:
        server.quit()