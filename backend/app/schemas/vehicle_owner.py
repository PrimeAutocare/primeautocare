from pydantic import BaseModel
from typing import Optional

class VehicleOwnerCreate(BaseModel):
    owner_name: str
    owner_phone: str
    owner_email: str

class VehicleOwnerResponse(BaseModel):
    owner_no: int
    owner_name: str
    owner_phone: str
    owner_email: str

    class Config:
        from_attributes = True

class VehicleOwnerUpdate(BaseModel):
    owner_name: Optional[str] = None
    owner_phone: Optional[str] = None
    owner_email: Optional[str] = None