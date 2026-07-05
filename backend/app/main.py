from fastapi import FastAPI
from app.routers import job
from app.routers import employee

app = FastAPI(title="PrimeAutocare API")

app.include_router(job.router)
app.include_router(employee.router)


@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}