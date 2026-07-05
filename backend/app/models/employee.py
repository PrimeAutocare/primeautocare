from sqlalchemy import Column, Integer, String, CHAR, Date
from app.database import Base

class Employee(Base):
    __tablename__ = "employee"

    emp_no = Column(Integer, primary_key=True)
    emp_gname = Column(String(15), nullable=False)
    emp_fname = Column(String(15), nullable=False)
    emp_phone = Column(String(13), nullable=False)
    emp_email = Column(String(30), nullable=False, unique=True)
    emp_passhash = Column(String(30), nullable=False)
    emp_role = Column(CHAR(1), nullable=False)
    emp_create_dt = Column(Date, nullable=False)