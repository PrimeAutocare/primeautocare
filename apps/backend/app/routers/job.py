from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.job import Job
from app.models.vehicle import Vehicle
from app.models.customer import Customer
from app.schemas.job import JobResponse, JobCreate, JobUpdate

router = APIRouter()

@router.get("/jobs", response_model=List[JobResponse])
def get_jobs(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return db.query(Job).order_by(Job.job_id.asc()).all()

@router.get("/jobs/assigned-to-me", response_model=List[JobResponse])
def get_my_jobs(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return (
        db.query(Job)
        .filter(Job.emp_no == current_employee.emp_no)
        .order_by(Job.job_id.asc())
        .all()
    )

@router.post("/jobs", response_model=JobResponse)
def create_job(job: JobCreate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    cust_no = job.cust_no

    if cust_no is None and job.cust_name:
        new_customer = Customer(
            cust_name=job.cust_name,
            cust_phone=job.cust_phone,
            cust_email=job.cust_email,
        )
        db.add(new_customer)
        db.flush()
        cust_no = new_customer.cust_no

    vehicle = db.query(Vehicle).filter(Vehicle.vehi_license == job.vehi_license).first()
    if vehicle is None:
        vehicle = Vehicle(
            cust_no=cust_no,
            vehi_license=job.vehi_license,
            vehi_make=job.vehi_make,
            vehi_model=job.vehi_model,
            vehi_year=job.vehi_year,
        )
        db.add(vehicle)
        db.flush()
    elif vehicle.cust_no is None and cust_no is not None:
        vehicle.cust_no = cust_no

    new_job = Job(
        job_no=job.job_no,
        vehi_id=vehicle.vehi_id,
        emp_no=job.emp_no,
        status="P",
        created_by=current_employee.emp_no,
    )
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    return new_job

@router.patch("/jobs/{job_id}", response_model=JobResponse)
def update_job(job_id: str, job_update: JobUpdate, db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    job = db.query(Job).filter(Job.job_id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    update_data = job_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(job, key, value)

    db.commit()
    db.refresh(job)
    return job

@router.delete("/jobs/{job_id}", status_code=204)
def delete_job(job_id: str, db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A", "S"))):
    job = db.query(Job).filter(Job.job_id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    db.delete(job)
    db.commit()
    return None
