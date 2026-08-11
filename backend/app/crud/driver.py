from sqlalchemy.orm import Session

from app.models.driver import Driver
from app.schemas.driver import DriverCreate, DriverUpdate


def create_driver(db: Session, driver: DriverCreate):
    db_driver = Driver(**driver.model_dump())
    db.add(db_driver)
    db.commit()
    db.refresh(db_driver)
    return db_driver


def get_drivers(db: Session):
    return db.query(Driver).all()


def get_driver(db: Session, driver_id):
    return db.query(Driver).filter(
        Driver.driver_id == driver_id
    ).first()


def update_driver(db: Session, driver_id, driver: DriverUpdate):
    db_driver = get_driver(db, driver_id)

    if not db_driver:
        return None

    for key, value in driver.model_dump(exclude_unset=True).items():
        setattr(db_driver, key, value)

    db.commit()
    db.refresh(db_driver)

    return db_driver


def delete_driver(db: Session, driver_id):
    db_driver = get_driver(db, driver_id)

    if not db_driver:
        return None

    db.delete(db_driver)
    db.commit()

    return db_driver