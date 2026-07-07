from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.employee import Employee
from app.schemas.employee import EmployeeResponse, EmployeeCreate

router = APIRouter()

@router.get("/employees", response_model=List[EmployeeResponse])
def get_employees(db: Session = Depends(get_db)):
    return db.query(Employee).all()

@router.post("/employees", response_model=EmployeeResponse)
def create_employee(employee: EmployeeCreate, db: Session = Depends(get_db)):
    new_employee = Employee(**employee.model_dump())
    db.add(new_employee)
    db.commit()
    db.refresh(new_employee)
    return new_employee