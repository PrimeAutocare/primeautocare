from pydantic import BaseModel
from datetime import date
from typing import Optional

class EmployeeCreate(BaseModel):
    emp_gname: str
    emp_fname: str
    emp_phone: str
    emp_email: str
    emp_passhash: str
    emp_role: str
    emp_create_dt: date

class EmployeeResponse(BaseModel):
    emp_no: str
    emp_gname: str
    emp_fname: str
    emp_phone: str
    emp_email: str
    emp_role: str
    emp_create_dt: date

    class Config:
        from_attributes = True

class EmployeeUpdate(BaseModel):
    emp_gname: Optional[str] = None
    emp_fname: Optional[str] = None
    emp_phone: Optional[str] = None
    emp_email: Optional[str] = None
    emp_role: Optional[str] = None