from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.vehicle import Vehicle
from app.schemas.vehicle import VehicleResponse, VehicleCreate

router = APIRouter()

@router.get("/vehicles", response_model=List[VehicleResponse])
def get_vehicles(db: Session = Depends(get_db)):
    return db.query(Vehicle).all()

@router.post("/vehicles", response_model=VehicleResponse)
def create_vehicle(vehicle: VehicleCreate, db: Session = Depends(get_db)):
    new_vehicle = Vehicle(**vehicle.model_dump())
    db.add(new_vehicle)
    db.commit()
    db.refresh(new_vehicle)
    return new_vehicle