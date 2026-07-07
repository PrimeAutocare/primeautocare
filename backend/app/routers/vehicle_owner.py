from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.vehicle_owner import VehicleOwner
from app.schemas.vehicle_owner import VehicleOwnerResponse, VehicleOwnerCreate, VehicleOwnerUpdate

router = APIRouter()

@router.get("/vehicle-owners", response_model=List[VehicleOwnerResponse])
def get_vehicle_owners(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(VehicleOwner).all()

@router.post("/vehicle-owners", response_model=VehicleOwnerResponse)
def create_vehicle_owner(owner: VehicleOwnerCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    new_owner = VehicleOwner(**owner.model_dump())
    db.add(new_owner)
    db.commit()
    db.refresh(new_owner)
    return new_owner

@router.patch("/vehicle-owners/{owner_no}", response_model=VehicleOwnerResponse)
def update_vehicle_owner(owner_no: int, owner_update: VehicleOwnerUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    owner = db.query(VehicleOwner).filter(VehicleOwner.owner_no == owner_no).first()
    if not owner:
        raise HTTPException(status_code=404, detail="Vehicle owner not found")

    update_data = owner_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(owner, key, value)

    db.commit()
    db.refresh(owner)
    return owner

@router.delete("/vehicle-owners/{owner_no}", status_code=204)
def delete_vehicle_owner(owner_no: int, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    owner = db.query(VehicleOwner).filter(VehicleOwner.owner_no == owner_no).first()
    if not owner:
        raise HTTPException(status_code=404, detail="Vehicle owner not found")

    db.delete(owner)
    db.commit()
    return None