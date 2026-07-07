from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base

class Vehicle(Base):
    __tablename__ = "vehicle"

    vehi_id = Column(Integer, primary_key=True)
    owner_no = Column(Integer, ForeignKey("vehicle_owner.owner_no"), nullable=False)
    vehi_license = Column(String(10), nullable=False)
    vehi_make = Column(String(20), nullable=False)
    vehi_model = Column(String(20), nullable=False)
    vehi_year = Column(Integer, nullable=False)