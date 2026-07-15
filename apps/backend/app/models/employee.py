from sqlalchemy import Column, String, CHAR, Date, Numeric, FetchedValue
from app.database import Base

class Employee(Base):
    __tablename__ = "employee"

    emp_no = Column(String(6), primary_key=True, server_default=FetchedValue())
    emp_gname = Column(String(15), nullable=False)
    emp_fname = Column(String(15), nullable=False)
    emp_phone = Column(String(13), nullable=False)
    emp_email = Column(String(30), nullable=False, unique=True)
    emp_passhash = Column(String(60), nullable=False)
    emp_role = Column(CHAR(1), nullable=False)
    emp_create_dt = Column(Date, nullable=False)
    emp_hourly_rate = Column(Numeric(7, 2), nullable=False)
