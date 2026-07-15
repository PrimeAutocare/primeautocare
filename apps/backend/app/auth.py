import os
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext
from dotenv import load_dotenv
from fastapi import Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.database import get_db
from app.models.employee import Employee

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 8  # 8 hour login session
security_scheme = HTTPBearer()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

def get_current_employee(request: Request, db: Session = Depends(get_db)) -> Employee:
    token = request.cookies.get("access_token")
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
    )
    if not token:
        raise credentials_exception
    try:
        payload = decode_access_token(token)
        emp_no: str = payload.get("sub")
        if emp_no is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    employee = db.query(Employee).filter(Employee.emp_no == emp_no).first()
    if employee is None:
        raise credentials_exception

    return employee

def require_role(*allowed_roles: str):
    def role_checker(current_employee: Employee = Depends(get_current_employee)) -> Employee:
        if current_employee.emp_role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action"
            )
        return current_employee
    return role_checker