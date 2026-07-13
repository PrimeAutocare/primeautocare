from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.schemas.employee import EmployeeResponse, EmployeeCreate, EmployeeUpdate

router = APIRouter()

@router.get("/employees", response_model=List[EmployeeResponse])
def get_employees(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Employee).order_by(Employee.emp_no.asc()).all()

@router.post("/employees", response_model=EmployeeResponse)
def create_employee(employee: EmployeeCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    new_employee = Employee(**employee.model_dump())
    db.add(new_employee)
    db.commit()
    db.refresh(new_employee)
    return new_employee

@router.patch("/employees/{emp_no}", response_model=EmployeeResponse)
def update_employee(emp_no: int, emp_update: EmployeeUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    employee = db.query(Employee).filter(Employee.emp_no == emp_no).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    update_data = emp_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(employee, key, value)

    db.commit()
    db.refresh(employee)
    return employee

@router.delete("/employees/{emp_no}", status_code=204)
def delete_employee(emp_no: int, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    employee = db.query(Employee).filter(Employee.emp_no == emp_no).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    db.delete(employee)
    db.commit()
    return None