from sqlalchemy.orm import Session

from app.models.fuel_record import FuelRecord
from app.schemas.fuel_record import (
    FuelRecordCreate,
    FuelRecordUpdate,
)


def create_fuel_record(db: Session, fuel: FuelRecordCreate):
    db_fuel = FuelRecord(**fuel.model_dump())
    db.add(db_fuel)
    db.commit()
    db.refresh(db_fuel)
    return db_fuel


def get_fuel_records(db: Session):
    return db.query(FuelRecord).all()


def get_fuel_record(db: Session, fuel_id):
    return db.query(FuelRecord).filter(
        FuelRecord.fuel_id == fuel_id
    ).first()


def update_fuel_record(db: Session, fuel_id, fuel: FuelRecordUpdate):
    db_fuel = get_fuel_record(db, fuel_id)

    if not db_fuel:
        return None

    for key, value in fuel.model_dump(exclude_unset=True).items():
        setattr(db_fuel, key, value)

    db.commit()
    db.refresh(db_fuel)

    return db_fuel


def delete_fuel_record(db: Session, fuel_id):
    db_fuel = get_fuel_record(db, fuel_id)

    if not db_fuel:
        return None

    db.delete(db_fuel)
    db.commit()

    return db_fuel