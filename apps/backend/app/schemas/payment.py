from pydantic import BaseModel
from datetime import date
from typing import Optional
from decimal import Decimal

class PaymentCreate(BaseModel):
    inv_no: str
    pay_date: date
    pay_amount: Decimal
    pay_method: str

class PaymentResponse(BaseModel):
    pay_no: str
    inv_no: str
    pay_date: date
    pay_amount: Decimal
    pay_method: str

    class Config:
        from_attributes = True

class PaymentUpdate(BaseModel):
    pay_date: Optional[date] = None
    pay_amount: Optional[Decimal] = None
    pay_method: Optional[str] = None
