from fastapi import FastAPI
from app.routers import job

app = FastAPI(title="PrimeAutocare API")

app.include_router(job.router)

@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}