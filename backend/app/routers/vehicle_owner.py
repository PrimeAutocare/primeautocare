from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.vehicle_owner import VehicleOwner
from app.schemas.vehicle_owner import VehicleOwnerResponse

router = APIRouter()

@router.get("/vehicle-owners", response_model=List[VehicleOwnerResponse])
def get_vehicle_owners(db: Session = Depends(get_db)):
    return db.query(VehicleOwner).all()