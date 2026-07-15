from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.payment import Payment
from app.schemas.payment import PaymentResponse, PaymentCreate, PaymentUpdate

router = APIRouter()

@router.get("/payments", response_model=List[PaymentResponse])
def get_payments(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Payment).order_by(Payment.pay_no.asc()).all()

@router.post("/payments", response_model=PaymentResponse)
def create_payment(payment: PaymentCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    new_payment = Payment(**payment.model_dump())
    db.add(new_payment)
    db.commit()
    db.refresh(new_payment)
    return new_payment

@router.patch("/payments/{pay_no}", response_model=PaymentResponse)
def update_payment(pay_no: str, payment_update: PaymentUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    payment = db.query(Payment).filter(Payment.pay_no == pay_no).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    update_data = payment_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(payment, key, value)

    db.commit()
    db.refresh(payment)
    return payment

@router.delete("/payments/{pay_no}", status_code=204)
def delete_payment(pay_no: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    payment = db.query(Payment).filter(Payment.pay_no == pay_no).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    db.delete(payment)
    db.commit()
    return None
