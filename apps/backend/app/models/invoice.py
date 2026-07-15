from sqlalchemy import Column, String, CHAR, Date, Numeric, ForeignKey, FetchedValue
from app.database import Base

class Invoice(Base):
    __tablename__ = "invoice"

    inv_no = Column(String(6), primary_key=True, server_default=FetchedValue())
    visit_id = Column(String(6), ForeignKey("vehicle_visit.visit_id"), nullable=False, unique=True)
    inv_date = Column(Date, nullable=False)
    inv_total = Column(Numeric(10, 2), nullable=False)
    inv_status = Column(CHAR(1), nullable=False)
