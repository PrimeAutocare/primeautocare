from datetime import datetime, date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.auth import get_current_employee, require_role
from app.database import get_db
from app.models.employee import Employee
from app.models.attendance import Attendance
from app.schemas.attendance import AttendanceResponse

router = APIRouter()

@router.post("/attendance/clock-in", response_model=AttendanceResponse)
def clock_in(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    open_record = (
        db.query(Attendance)
        .filter(Attendance.emp_no == current_employee.emp_no, Attendance.clock_out.is_(None))
        .first()
    )
    if open_record:
        raise HTTPException(status_code=409, detail="Already clocked in")

    now = datetime.now()
    record = Attendance(emp_no=current_employee.emp_no, clock_in=now, att_date=now.date())
    db.add(record)
    db.commit()
    db.refresh(record)
    return record

@router.post("/attendance/clock-out", response_model=AttendanceResponse)
def clock_out(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    record = (
        db.query(Attendance)
        .filter(Attendance.emp_no == current_employee.emp_no, Attendance.clock_out.is_(None))
        .first()
    )
    if not record:
        raise HTTPException(status_code=409, detail="Not clocked in")

    now = datetime.now()
    record.clock_out = now
    elapsed_hours = (now - record.clock_in).total_seconds() / 3600
    record.total_hours = Decimal(str(round(elapsed_hours, 2)))
    db.commit()
    db.refresh(record)
    return record

@router.get("/attendance/me", response_model=List[AttendanceResponse])
def get_my_attendance(db: Session = Depends(get_db), current_employee: Employee = Depends(get_current_employee)):
    return (
        db.query(Attendance)
        .filter(Attendance.emp_no == current_employee.emp_no)
        .order_by(Attendance.att_id.desc())
        .all()
    )

@router.get("/attendance", response_model=List[AttendanceResponse])
def get_all_attendance(db: Session = Depends(get_db), current_employee: Employee = Depends(require_role("A"))):
    return db.query(Attendance).order_by(Attendance.att_id.desc()).all()
