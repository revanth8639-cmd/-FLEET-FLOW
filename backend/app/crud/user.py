from sqlalchemy.orm import Session

from app.models.user import User
from app.core.security import hash_password
from datetime import datetime

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def update_user(db: Session, user: User, **values):
    for key, value in values.items():
        if value is not None:
            setattr(user, key, value)
    db.commit()
    db.refresh(user)
    return user


def create_user(
    db: Session,
    email: str,
    password: str,
    full_name: str,
    phone: str,
    role,
):
    user = User(
        email=email,
        password=hash_password(password),
        full_name=full_name,
        phone=phone,
        role=role,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user

