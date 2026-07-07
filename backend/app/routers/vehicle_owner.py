from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.vehicle_owner import VehicleOwner
from app.schemas.vehicle_owner import VehicleOwnerResponse, VehicleOwnerCreate

router = APIRouter()

@router.get("/vehicle-owners", response_model=List[VehicleOwnerResponse])
def get_vehicle_owners(db: Session = Depends(get_db)):
    return db.query(VehicleOwner).all()

@router.post("/vehicle-owners", response_model=VehicleOwnerResponse)
def create_vehicle_owner(owner: VehicleOwnerCreate, db: Session = Depends(get_db)):
    new_owner = VehicleOwner(**owner.model_dump())
    db.add(new_owner)
    db.commit()
    db.refresh(new_owner)
    return new_owner