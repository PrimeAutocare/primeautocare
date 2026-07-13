from sqlalchemy import Column, Integer, CHAR, Date, ForeignKey
from app.database import Base

class VehicleVisit(Base):
    __tablename__ = "vehicle_visit"

    visit_id = Column(Integer, primary_key=True)
    vehi_id = Column(Integer, ForeignKey("vehicle.vehi_id"), nullable=False)
    visit_check_in_dt = Column(Date, nullable=False)
    visit_check_out_dt = Column(Date, nullable=True)
    visit_status = Column(CHAR(1), nullable=False)