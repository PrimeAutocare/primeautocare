from pydantic import BaseModel
from typing import Optional

class CustomerCreate(BaseModel):
    cust_name: str
    cust_phone: str
    cust_email: str

class CustomerResponse(BaseModel):
    cust_no: str
    cust_name: str
    cust_phone: str
    cust_email: str

    class Config:
        from_attributes = True

class CustomerUpdate(BaseModel):
    cust_name: Optional[str] = None
    cust_phone: Optional[str] = None
    cust_email: Optional[str] = None
