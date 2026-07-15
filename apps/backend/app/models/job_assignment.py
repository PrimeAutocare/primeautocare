from sqlalchemy import Column, String, CHAR, Date, Numeric, ForeignKey, FetchedValue
from app.database import Base

class JobAssignment(Base):
    __tablename__ = "job_assignment"

    jobassign_id = Column(String(6), primary_key=True, server_default=FetchedValue())
    visit_id = Column(String(6), ForeignKey("vehicle_visit.visit_id"), nullable=False)
    job_no = Column(String(6), ForeignKey("job.job_no"), nullable=False)
    jobassign_assigned_by = Column(String(6), ForeignKey("employee.emp_no"), nullable=False)
    jobassign_assign_dt = Column(Date, nullable=False)
    jobassign_start_dt = Column(Date, nullable=True)
    jobassign_complete_dt = Column(Date, nullable=True)
    jobassign_status = Column(CHAR(1), nullable=False)
    jobassign_cost = Column(Numeric(9, 2), nullable=True)
    jobassign_notes = Column(String(100), nullable=True)
