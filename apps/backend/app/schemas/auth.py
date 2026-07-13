from pydantic import BaseModel

class LoginRequest(BaseModel):
    emp_email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"