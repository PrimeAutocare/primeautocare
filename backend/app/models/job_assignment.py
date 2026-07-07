from sqlalchemy import Column, Integer, CHAR, Date, Numeric, String, ForeignKey
from app.database import Base

class JobAssignment(Base):
    __tablename__ = "job_assignment"

    jobassign_id = Column(Integer, primary_key=True)
    visit_id = Column(Integer, ForeignKey("vehicle_visit.visit_id"), nullable=False)
    job_no = Column(Integer, ForeignKey("job.job_no"), nullable=False)
    jobassign_assigned_by = Column(Integer, ForeignKey("employee.emp_no"), nullable=False)
    jobassign_assign_dt = Column(Date, nullable=False)
    jobassign_start_dt = Column(Date, nullable=True)
    jobassign_complete_dt = Column(Date, nullable=True)
    jobassign_status = Column(CHAR(1), nullable=False)
    jobassign_cost = Column(Numeric(9, 2), nullable=True)
    jobassign_notes = Column(String(100), nullable=True)