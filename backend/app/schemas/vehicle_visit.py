from pydantic import BaseModel
from datetime import date
from typing import Optional

class VehicleVisitResponse(BaseModel):
    visit_id: int
    vehi_id: int
    visit_check_in_dt: date
    visit_check_out_dt: Optional[date] = None
    visit_status: str

    class Config:
        from_attributes = True