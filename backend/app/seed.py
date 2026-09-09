"""Seed initial users into the database if not present."""

from app.database import SessionLocal
from app.models.user import User, RoleEnum

INITIAL_USERS = [
    {
        "email": "revanth8639@gmail.com",
        "password": "$2b$12$mI5UMw8pnFZ0FyMPQ9ejqeELhKfRK0MCZmbpEXhjh63jSVa/HseA6",
        "full_name": "Revanth Reddy",
        "phone": "8639526641",
        "role": RoleEnum.FleetManager,
    },
    {
        "email": "revanth8638@gmail.com",
        "password": "$2b$12$yDDJmM9PMLHufR7E.Zs/Qe4Eu3gVFEjiyz44RVE.deBfaCvqHD5Dq",
        "full_name": "Revanth Reddy",
        "phone": "8639526641",
        "role": RoleEnum.FleetManager,
    },
    {
        "email": "vennapusauday.aiml@sandipuniversity.edu.in",
        "password": "$2b$12$bMJU4rEYKyg5LT7WeJSpDuFKrMyWfOis.lODusPCOLLM5sdIqrP6G",
        "full_name": "Uday Kiran Reddy",
        "phone": "7416818182",
        "role": RoleEnum.Admin,
    },
    {
        "email": "manoharmanohar52808@gmail.com",
        "password": "$2b$12$86lngwZnVce8XOQrOzDOPuftZryj3478FWaWBnLVj/IhH3v6wjvZ.",
        "full_name": "manohar",
        "phone": "8978456290",
        "role": RoleEnum.Driver,
    },
    {
        "email": "reddydhani8639@gmail.com",
        "password": "$2b$12$Ua.KkI2TCJ1VYFbYwXXq.OoYqBt05zD4P7Qax90lxeSOjsRFpgXW6",
        "full_name": "Dhanireddy",
        "phone": "8639526641",
        "role": RoleEnum.Dispatcher,
    },
    {
        "email": "vukreddy943@gmail.com",
        "password": "$2b$12$Ww6p7Wk1sfzBPYXOp89nJOhNhRTyrMHnt9uDty17yhsBUqMdC5Oii",
        "full_name": "Kiran Reddy",
        "phone": "7416818182",
        "role": RoleEnum.Driver,
    },
]


def seed_default_users():
    db = SessionLocal()
    try:
        for u_data in INITIAL_USERS:
            existing = db.query(User).filter(User.email == u_data["email"]).first()
            if not existing:
                user = User(
                    email=u_data["email"],
                    password=u_data["password"],
                    full_name=u_data["full_name"],
                    phone=u_data["phone"],
                    role=u_data["role"],
                )
                db.add(user)
        db.commit()
    except Exception as exc:
        db.rollback()
        print(f"User seeding skipped/deferred: {exc}")
    finally:
        db.close()
