from pydantic import BaseModel
from datetime import date
from typing import Optional

class VehicleVisitCreate(BaseModel):
    vehi_id: int
    visit_check_in_dt: date
    visit_check_out_dt: Optional[date] = None
    visit_status: str

class VehicleVisitResponse(BaseModel):
    visit_id: int
    vehi_id: int
    visit_check_in_dt: date
    visit_check_out_dt: Optional[date] = None
    visit_status: str

    class Config:
        from_attributes = True

class VehicleVisitUpdate(BaseModel):
    visit_check_out_dt: Optional[date] = None
    visit_status: Optional[str] = None