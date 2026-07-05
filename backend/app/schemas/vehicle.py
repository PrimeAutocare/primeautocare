from pydantic import BaseModel

class VehicleResponse(BaseModel):
    vehi_id: int
    owner_no: int
    vehi_license: str
    vehi_make: str
    vehi_model: str
    vehi_year: int

    class Config:
        from_attributes = True