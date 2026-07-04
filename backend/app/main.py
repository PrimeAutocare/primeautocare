from fastapi import FastAPI

app = FastAPI(title="PrimeAutocare API")

@app.get("/")
def root():
    return {"message": "PrimeAutocare API is running"}