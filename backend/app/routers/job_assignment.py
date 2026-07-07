from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models.job_assignment import JobAssignment
from app.schemas.job_assignment import JobAssignmentResponse, JobAssignmentCreate, JobAssignmentUpdate

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

@router.patch("/job-assignments/{jobassign_id}", response_model=JobAssignmentResponse)
def update_job_assignment(jobassign_id: int, assignment_update: JobAssignmentUpdate, db: Session = Depends(get_db)):
    assignment = db.query(JobAssignment).filter(JobAssignment.jobassign_id == jobassign_id).first()
    if not assignment:
        raise HTTPException(status_code=404, detail="Job assignment not found")

    update_data = assignment_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(assignment, key, value)

    db.commit()
    db.refresh(assignment)
    return assignment

@router.delete("/job-assignments/{jobassign_id}", status_code=204)
def delete_job_assignment(jobassign_id: int, db: Session = Depends(get_db)):
    assignment = db.query(JobAssignment).filter(JobAssignment.jobassign_id == jobassign_id).first()
    if not assignment:
        raise HTTPException(status_code=404, detail="Job assignment not found")

    db.delete(assignment)
    db.commit()
    return None