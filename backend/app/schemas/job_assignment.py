from pydantic import BaseModel
from datetime import date
from typing import Optional
from decimal import Decimal

class JobAssignmentCreate(BaseModel):
    visit_id: int
    job_no: int
    jobassign_assigned_by: int
    jobassign_assign_dt: date
    jobassign_start_dt: Optional[date] = None
    jobassign_complete_dt: Optional[date] = None
    jobassign_status: str
    jobassign_cost: Optional[Decimal] = None
    jobassign_notes: Optional[str] = None

class JobAssignmentResponse(BaseModel):
    jobassign_id: int
    visit_id: int
    job_no: int
    jobassign_assigned_by: int
    jobassign_assign_dt: date
    jobassign_start_dt: Optional[date] = None
    jobassign_complete_dt: Optional[date] = None
    jobassign_status: str
    jobassign_cost: Optional[Decimal] = None
    jobassign_notes: Optional[str] = None

    class Config:
        from_attributes = True