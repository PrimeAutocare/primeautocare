from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.vehicle_visit import VehicleVisit
from app.schemas.vehicle_visit import VehicleVisitResponse, VehicleVisitCreate, VehicleVisitUpdate

router = APIRouter()

@router.get("/vehicle-visits", response_model=List[VehicleVisitResponse])
def get_vehicle_visits(db: Session = Depends(get_db)):
    return db.query(VehicleVisit).all()

@router.post("/vehicle-visits", response_model=VehicleVisitResponse)
def create_vehicle_visit(visit: VehicleVisitCreate, db: Session = Depends(get_db)):
    new_visit = VehicleVisit(**visit.model_dump())
    db.add(new_visit)
    db.commit()
    db.refresh(new_visit)
    return new_visit

@router.patch("/vehicle-visits/{visit_id}", response_model=VehicleVisitResponse)
def update_vehicle_visit(visit_id: int, visit_update: VehicleVisitUpdate, db: Session = Depends(get_db)):
    visit = db.query(VehicleVisit).filter(VehicleVisit.visit_id == visit_id).first()
    if not visit:
        raise HTTPException(status_code=404, detail="Vehicle visit not found")

    update_data = visit_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(visit, key, value)

    db.commit()
    db.refresh(visit)
    return visit

@router.delete("/vehicle-visits/{visit_id}", status_code=204)
def delete_vehicle_visit(visit_id: int, db: Session = Depends(get_db)):
    visit = db.query(VehicleVisit).filter(VehicleVisit.visit_id == visit_id).first()
    if not visit:
        raise HTTPException(status_code=404, detail="Vehicle visit not found")

    db.delete(visit)
    db.commit()
    return None