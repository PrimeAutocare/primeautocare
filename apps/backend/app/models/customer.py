from sqlalchemy import Column, String, FetchedValue
from app.database import Base

class Customer(Base):
    __tablename__ = "customer"

    cust_no = Column(String(6), primary_key=True, server_default=FetchedValue())
    cust_name = Column(String(30), nullable=False)
    cust_phone = Column(String(13), nullable=False)
    cust_email = Column(String(30), nullable=False, unique=True)
