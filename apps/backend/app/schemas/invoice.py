from pydantic import BaseModel
from datetime import date
from typing import Optional
from decimal import Decimal

class InvoiceCreate(BaseModel):
    visit_id: str
    inv_date: date
    inv_total: Decimal
    inv_status: str

class InvoiceResponse(BaseModel):
    inv_no: str
    visit_id: str
    inv_date: date
    inv_total: Decimal
    inv_status: str

    class Config:
        from_attributes = True

class InvoiceUpdate(BaseModel):
    inv_date: Optional[date] = None
    inv_total: Optional[Decimal] = None
    inv_status: Optional[str] = None
