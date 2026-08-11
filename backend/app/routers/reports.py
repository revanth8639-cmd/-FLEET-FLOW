from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.reports import (
    ReportsSummary,
    ShipmentReport,
    TripReport,
    VehicleReport,
    FuelReport,
    MaintenanceReport,
)

from app.crud.reports import (
    get_reports_summary,
    get_shipment_report,
    get_trip_report,
    get_vehicle_report,
    get_fuel_report,
    get_maintenance_report,
)


router = APIRouter(
    prefix="/reports",
    tags=["Reports & Analytics"]
)


@router.get(
    "/summary",
    response_model=ReportsSummary
)
def reports_summary(
    db: Session = Depends(get_db)
):
    return get_reports_summary(db)


@router.get(
    "/shipments",
    response_model=ShipmentReport
)
def shipment_reports(
    db: Session = Depends(get_db)
):
    return get_shipment_report(db)


@router.get(
    "/trips",
    response_model=TripReport
)
def trip_reports(
    db: Session = Depends(get_db)
):
    return get_trip_report(db)


@router.get(
    "/vehicles",
    response_model=VehicleReport
)
def vehicle_reports(
    db: Session = Depends(get_db)
):
    return get_vehicle_report(db)


@router.get(
    "/fuel",
    response_model=FuelReport
)
def fuel_reports(
    db: Session = Depends(get_db)
):
    return get_fuel_report(db)


@router.get(
    "/maintenance",
    response_model=MaintenanceReport
)
def maintenance_reports(
    db: Session = Depends(get_db)
):
    return get_maintenance_report(db)