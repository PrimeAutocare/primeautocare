from pydantic import BaseModel
from typing import Optional

class JobTypeCreate(BaseModel):
    job_desc: str

class JobTypeResponse(BaseModel):
    job_no: str
    job_desc: str

    class Config:
        from_attributes = True

class JobTypeUpdate(BaseModel):
    job_desc: Optional[str] = None
