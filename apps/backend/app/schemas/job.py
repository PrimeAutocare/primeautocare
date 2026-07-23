from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from decimal import Decimal

class JobCreate(BaseModel):
    """Create-job transaction payload: vehicle lookup/creation + job insert."""
    vehi_license: str
    vehi_make: Optional[str] = None
    vehi_model: Optional[str] = None
    vehi_year: Optional[int] = None
    cust_no: Optional[str] = None
    cust_name: Optional[str] = None
    cust_phone: Optional[str] = None
    cust_email: Optional[str] = None
    job_no: str
    emp_no: str

class JobResponse(BaseModel):
    job_id: str
    job_no: str
    vehi_id: str
    emp_no: str
    performed_by: Optional[str] = None
    status: str
    hours: Optional[Decimal] = None
    cost: Optional[Decimal] = None
    notes: Optional[str] = None
    created_by: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class JobUpdate(BaseModel):
    performed_by: Optional[str] = None
    status: Optional[str] = None
    hours: Optional[Decimal] = None
    cost: Optional[Decimal] = None
    notes: Optional[str] = None
