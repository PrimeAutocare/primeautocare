from pydantic import BaseModel

class JobResponse(BaseModel):
    job_no: int
    job_desc: str

    class Config:
        from_attributes = True