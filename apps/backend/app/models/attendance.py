from sqlalchemy import Column, String, Date, Numeric, ForeignKey, TIMESTAMP, FetchedValue
from sqlalchemy.sql import func
from app.database import Base

class Attendance(Base):
    __tablename__ = "attendance"

    att_id = Column(String(6), primary_key=True, server_default=FetchedValue())
    emp_no = Column(String(6), ForeignKey("employee.emp_no"), nullable=False)
    clock_in = Column(TIMESTAMP(timezone=False), nullable=False)
    clock_out = Column(TIMESTAMP(timezone=False), nullable=True)
    att_date = Column(Date, nullable=False)
    total_hours = Column(Numeric(5, 2), nullable=True)
    created_at = Column(TIMESTAMP(timezone=False), nullable=False, server_default=func.now())
