from pydantic import BaseModel
from typing import Optional

class JobCreate(BaseModel):
    job_desc: str

class JobResponse(BaseModel):
    job_no: int
    job_desc: str

    class Config:
        from_attributes = True

class JobUpdate(BaseModel):
    job_desc: Optional[str] = None