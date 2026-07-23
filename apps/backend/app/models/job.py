from sqlalchemy import Column, String, CHAR, Numeric, ForeignKey, TIMESTAMP, FetchedValue
from sqlalchemy.sql import func
from app.database import Base

class Job(Base):
    __tablename__ = "jobs"

    job_id = Column(String(6), primary_key=True, server_default=FetchedValue())
    job_no = Column(String(6), ForeignKey("job.job_no"), nullable=False)
    vehi_id = Column(String(6), ForeignKey("vehicle.vehi_id"), nullable=False)
    emp_no = Column(String(6), ForeignKey("employee.emp_no"), nullable=False)
    performed_by = Column(String(6), ForeignKey("employee.emp_no"), nullable=True)
    status = Column(CHAR(1), nullable=False)
    hours = Column(Numeric(5, 2), nullable=True)
    cost = Column(Numeric(9, 2), nullable=True)
    notes = Column(String(100), nullable=True)
    created_by = Column(String(6), ForeignKey("employee.emp_no"), nullable=False)
    created_at = Column(TIMESTAMP(timezone=False), nullable=False, server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=False), nullable=False, server_default=func.now(), onupdate=func.now())
