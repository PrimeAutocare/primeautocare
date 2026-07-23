from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.job_type import JobType
from app.schemas.job_type import JobTypeResponse, JobTypeCreate, JobTypeUpdate

router = APIRouter()

@router.get("/job-types", response_model=List[JobTypeResponse])
def get_job_types(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(JobType).order_by(JobType.job_no.asc()).all()

@router.post("/job-types", response_model=JobTypeResponse)
def create_job_type(job_type: JobTypeCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    new_job_type = JobType(**job_type.model_dump())
    db.add(new_job_type)
    db.commit()
    db.refresh(new_job_type)
    return new_job_type

@router.patch("/job-types/{job_no}", response_model=JobTypeResponse)
def update_job_type(job_no: str, job_type_update: JobTypeUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    job_type = db.query(JobType).filter(JobType.job_no == job_no).first()
    if not job_type:
        raise HTTPException(status_code=404, detail="Job type not found")

    update_data = job_type_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(job_type, key, value)

    db.commit()
    db.refresh(job_type)
    return job_type

@router.delete("/job-types/{job_no}", status_code=204)
def delete_job_type(job_no: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    job_type = db.query(JobType).filter(JobType.job_no == job_no).first()
    if not job_type:
        raise HTTPException(status_code=404, detail="Job type not found")

    db.delete(job_type)
    db.commit()
    return None
