from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import job, employee, customer, vehicle, vehicle_visit, job_assignment, auth

app = FastAPI(title="PrimeAutocare API")

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
app.include_router(auth.router)

@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}