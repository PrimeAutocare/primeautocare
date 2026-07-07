from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.job import Job
from app.schemas.job import JobResponse, JobCreate

router = APIRouter()

@router.get("/jobs", response_model=List[JobResponse])
def get_jobs(db: Session = Depends(get_db)):
    return db.query(Job).all()

@router.post("/jobs", response_model=JobResponse)
def create_job(job: JobCreate, db: Session = Depends(get_db)):
    new_job = Job(**job.model_dump())
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    return new_job