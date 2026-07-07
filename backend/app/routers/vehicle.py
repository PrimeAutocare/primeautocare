from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.vehicle import Vehicle
from app.schemas.vehicle import VehicleResponse, VehicleCreate, VehicleUpdate

router = APIRouter()

@router.get("/vehicles", response_model=List[VehicleResponse])
def get_vehicles(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Vehicle).all()

@router.post("/vehicles", response_model=VehicleResponse)
def create_vehicle(vehicle: VehicleCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    new_vehicle = Vehicle(**vehicle.model_dump())
    db.add(new_vehicle)
    db.commit()
    db.refresh(new_vehicle)
    return new_vehicle

@router.patch("/vehicles/{vehi_id}", response_model=VehicleResponse)
def update_vehicle(vehi_id: int, vehicle_update: VehicleUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    vehicle = db.query(Vehicle).filter(Vehicle.vehi_id == vehi_id).first()
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    update_data = vehicle_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(vehicle, key, value)

    db.commit()
    db.refresh(vehicle)
    return vehicle

@router.delete("/vehicles/{vehi_id}", status_code=204)
def delete_vehicle(vehi_id: int, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    vehicle = db.query(Vehicle).filter(Vehicle.vehi_id == vehi_id).first()
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    db.delete(vehicle)
    db.commit()
    return None