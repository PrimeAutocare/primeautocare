from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional
from decimal import Decimal

class AttendanceResponse(BaseModel):
    att_id: str
    emp_no: str
    clock_in: datetime
    clock_out: Optional[datetime] = None
    att_date: date
    total_hours: Optional[Decimal] = None

    class Config:
        from_attributes = True
