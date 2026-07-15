from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.invoice import Invoice
from app.schemas.invoice import InvoiceResponse, InvoiceCreate, InvoiceUpdate

router = APIRouter()

@router.get("/invoices", response_model=List[InvoiceResponse])
def get_invoices(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Invoice).order_by(Invoice.inv_no.asc()).all()

@router.post("/invoices", response_model=InvoiceResponse)
def create_invoice(invoice: InvoiceCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    new_invoice = Invoice(**invoice.model_dump())
    db.add(new_invoice)
    db.commit()
    db.refresh(new_invoice)
    return new_invoice

@router.patch("/invoices/{inv_no}", response_model=InvoiceResponse)
def update_invoice(inv_no: str, invoice_update: InvoiceUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    invoice = db.query(Invoice).filter(Invoice.inv_no == inv_no).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")

    update_data = invoice_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(invoice, key, value)

    db.commit()
    db.refresh(invoice)
    return invoice

@router.delete("/invoices/{inv_no}", status_code=204)
def delete_invoice(inv_no: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    invoice = db.query(Invoice).filter(Invoice.inv_no == inv_no).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")

    db.delete(invoice)
    db.commit()
    return None
