from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import IntegrityError

from app.routers import job, employee, customer, vehicle, vehicle_visit, job_assignment, invoice, payment, auth

app = FastAPI(title="PrimeAutocare API")

@app.exception_handler(IntegrityError)
def handle_integrity_error(request: Request, exc: IntegrityError):
    """Database constraints (unique keys, FKs, the labour/billing CHECKs) are
    business rules. Report them as 409 rather than letting them surface as 500."""
    detail = str(getattr(exc, "orig", exc)).strip().splitlines()[0]
    return JSONResponse(status_code=409, content={"detail": detail})

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(job.router)
app.include_router(employee.router)
app.include_router(customer.router)
app.include_router(vehicle.router)
app.include_router(vehicle_visit.router)
app.include_router(job_assignment.router)
app.include_router(invoice.router)
app.include_router(payment.router)
app.include_router(auth.router)

@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}