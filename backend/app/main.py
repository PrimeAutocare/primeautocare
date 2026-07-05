from fastapi import FastAPI
from app.routers import job, employee, vehicle_owner, vehicle, vehicle_visit, job_assignment

app = FastAPI(title="PrimeAutocare API")

app.include_router(job.router)
app.include_router(employee.router)
app.include_router(vehicle_owner.router)
app.include_router(vehicle.router)
app.include_router(vehicle_visit.router)
app.include_router(job_assignment.router)

@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}