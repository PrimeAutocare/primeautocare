from sqlalchemy import Column, Integer, String
from app.database import Base

class Job(Base):
    __tablename__ = "job"

    job_no = Column(Integer, primary_key=True)
    job_desc = Column(String(60), nullable=False)