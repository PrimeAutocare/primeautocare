from sqlalchemy import Column, Integer, String, ForeignKey, FetchedValue
from app.database import Base

class Vehicle(Base):
    __tablename__ = "vehicle"

    vehi_id = Column(String(6), primary_key=True, server_default=FetchedValue())
    cust_no = Column(String(6), ForeignKey("customer.cust_no"), nullable=False)
    vehi_license = Column(String(10), nullable=False)
    vehi_make = Column(String(20), nullable=False)
    vehi_model = Column(String(20), nullable=False)
    vehi_year = Column(Integer, nullable=False)
