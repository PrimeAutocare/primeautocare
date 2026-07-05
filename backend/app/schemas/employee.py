from pydantic import BaseModel
from datetime import date

class EmployeeResponse(BaseModel):
    emp_no: int
    emp_gname: str
    emp_fname: str
    emp_phone: str
    emp_email: str
    emp_role: str
    emp_create_dt: date

    class Config:
        from_attributes = True