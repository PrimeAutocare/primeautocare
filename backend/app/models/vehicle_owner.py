from sqlalchemy import Column, Integer, String
from app.database import Base

class VehicleOwner(Base):
    __tablename__ = "vehicle_owner"

    owner_no = Column(Integer, primary_key=True)
    owner_name = Column(String(30), nullable=False)
    owner_phone = Column(String(13), nullable=False)
    owner_email = Column(String(30), nullable=False, unique=True)