from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.vehicle_visit import VehicleVisit
from app.schemas.vehicle_visit import VehicleVisitResponse

router = APIRouter()

@router.get("/vehicle-visits", response_model=List[VehicleVisitResponse])
def get_vehicle_visits(db: Session = Depends(get_db)):
    return db.query(VehicleVisit).all()