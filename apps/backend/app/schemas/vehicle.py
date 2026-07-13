from pydantic import BaseModel
from typing import Optional

class VehicleCreate(BaseModel):
    owner_no: int
    vehi_license: str
    vehi_make: str
    vehi_model: str
    vehi_year: int

class VehicleResponse(BaseModel):
    vehi_id: int
    owner_no: int
    vehi_license: str
    vehi_make: str
    vehi_model: str
    vehi_year: int

    class Config:
        from_attributes = True

class VehicleUpdate(BaseModel):
    owner_no: Optional[int] = None
    vehi_license: Optional[str] = None
    vehi_make: Optional[str] = None
    vehi_model: Optional[str] = None
    vehi_year: Optional[int] = None