from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.employee import Employee
from app.schemas.auth import LoginRequest, TokenResponse
from app.auth import verify_password, create_access_token

router = APIRouter()

@router.post("/login", response_model=TokenResponse)
def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.emp_email == credentials.emp_email).first()

    if not employee or not verify_password(credentials.password, employee.emp_passhash):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(employee.emp_no), "role": employee.emp_role})
    return TokenResponse(access_token=token)