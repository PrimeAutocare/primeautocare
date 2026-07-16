import os

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.employee import Employee
from app.schemas.employee import EmployeeResponse
from app.schemas.auth import LoginRequest
from app.auth import verify_password, create_access_token, get_current_employee

router = APIRouter()

# Vercel sets VERCEL_ENV to "production"/"preview"/"development" automatically,
# so deployed environments get a secure cookie with no manual config needed;
# local dev (VERCEL_ENV unset) still runs over plain HTTP.
COOKIE_SECURE = os.getenv("VERCEL_ENV") in ("production", "preview")

@router.post("/login")
def login(credentials: LoginRequest, response: Response, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.emp_email == credentials.emp_email).first()

    if not employee or not verify_password(credentials.password, employee.emp_passhash):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(employee.emp_no), "role": employee.emp_role})

    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        samesite="lax",
        secure=COOKIE_SECURE,
        max_age=60 * 60 * 8,  # 8 hours, matches token expiry
    )

    return {"message": "Login successful", "role": employee.emp_role}

@router.get("/me", response_model=EmployeeResponse)
def get_me(current_employee: Employee = Depends(get_current_employee)):
    return current_employee

@router.post("/logout")
def logout(response: Response):
    response.delete_cookie("access_token")
    return {"message": "Logged out"}