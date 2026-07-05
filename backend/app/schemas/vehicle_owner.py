from pydantic import BaseModel

class VehicleOwnerResponse(BaseModel):
    owner_no: int
    owner_name: str
    owner_phone: str
    owner_email: str

    class Config:
        from_attributes = True