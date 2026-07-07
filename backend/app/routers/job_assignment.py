from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.job_assignment import JobAssignment
from app.schemas.job_assignment import JobAssignmentResponse, JobAssignmentCreate

router = APIRouter()

@router.get("/job-assignments", response_model=List[JobAssignmentResponse])
def get_job_assignments(db: Session = Depends(get_db)):
    return db.query(JobAssignment).all()

@router.post("/job-assignments", response_model=JobAssignmentResponse)
def create_job_assignment(assignment: JobAssignmentCreate, db: Session = Depends(get_db)):
    new_assignment = JobAssignment(**assignment.model_dump())
    db.add(new_assignment)
    db.commit()
    db.refresh(new_assignment)
    return new_assignment