from sqlalchemy import Column, String, CHAR, Date, ForeignKey, FetchedValue
from app.database import Base

class VehicleVisit(Base):
    __tablename__ = "vehicle_visit"

    visit_id = Column(String(6), primary_key=True, server_default=FetchedValue())
    vehi_id = Column(String(6), ForeignKey("vehicle.vehi_id"), nullable=False)
    visit_check_in_dt = Column(Date, nullable=False)
    visit_check_out_dt = Column(Date, nullable=True)
    visit_status = Column(CHAR(1), nullable=False)
