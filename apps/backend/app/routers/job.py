from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.job import Job
from app.schemas.job import JobResponse, JobCreate, JobUpdate

router = APIRouter()

@router.get("/jobs", response_model=List[JobResponse])
def get_jobs(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Job).order_by(Job.job_no.asc()).all()

@router.post("/jobs", response_model=JobResponse)
def create_job(job: JobCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    new_job = Job(**job.model_dump())
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    return new_job

@router.patch("/jobs/{job_no}", response_model=JobResponse)
def update_job(job_no: str, job_update: JobUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    job = db.query(Job).filter(Job.job_no == job_no).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    update_data = job_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(job, key, value)

    db.commit()
    db.refresh(job)
    return job

@router.delete("/jobs/{job_no}", status_code=204)
def delete_job(job_no: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    job = db.query(Job).filter(Job.job_no == job_no).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    db.delete(job)
    db.commit()
    return None