from sqlalchemy import Column, String, CHAR, Date, Numeric, ForeignKey, FetchedValue
from app.database import Base

class Payment(Base):
    __tablename__ = "payment"

    pay_no = Column(String(6), primary_key=True, server_default=FetchedValue())
    inv_no = Column(String(6), ForeignKey("invoice.inv_no"), nullable=False)
    pay_date = Column(Date, nullable=False)
    pay_amount = Column(Numeric(10, 2), nullable=False)
    pay_method = Column(CHAR(1), nullable=False)
