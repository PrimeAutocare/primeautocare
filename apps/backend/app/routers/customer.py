from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.customer import Customer
from app.schemas.customer import CustomerResponse, CustomerCreate, CustomerUpdate

router = APIRouter()

@router.get("/customers", response_model=List[CustomerResponse])
def get_customers(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Customer).order_by(Customer.cust_no.asc()).all()

@router.get("/customers/search", response_model=List[CustomerResponse])
def search_customers(q: str, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    pattern = f"%{q}%"
    return (
        db.query(Customer)
        .filter(
            Customer.cust_name.ilike(pattern)
            | Customer.cust_phone.ilike(pattern)
            | Customer.cust_email.ilike(pattern)
        )
        .order_by(Customer.cust_no.asc())
        .limit(20)
        .all()
    )

@router.post("/customers", response_model=CustomerResponse)
def create_customer(customer: CustomerCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    new_customer = Customer(**customer.model_dump())
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer

@router.patch("/customers/{cust_no}", response_model=CustomerResponse)
def update_customer(cust_no: str, customer_update: CustomerUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    customer = db.query(Customer).filter(Customer.cust_no == cust_no).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    update_data = customer_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(customer, key, value)

    db.commit()
    db.refresh(customer)
    return customer

@router.delete("/customers/{cust_no}", status_code=204)
def delete_customer(cust_no: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    customer = db.query(Customer).filter(Customer.cust_no == cust_no).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    db.delete(customer)
    db.commit()
    return None
