from sqlalchemy import Column, String, FetchedValue
from app.database import Base

class JobType(Base):
    __tablename__ = "job"

    job_no = Column(String(6), primary_key=True, server_default=FetchedValue())
    job_desc = Column(String(60), nullable=False)
