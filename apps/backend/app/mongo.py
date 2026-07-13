import os
from datetime import datetime, timezone, date
from decimal import Decimal
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")

mongo_client = MongoClient(MONGO_URI)
mongo_db = mongo_client["primeautocare"]

assignment_logs = mongo_db["assignment_logs"]

def _serialize_value(value):
    if isinstance(value, date):
        return value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    return value

def log_assignment_event(jobassign_id: int, event: str, changed_by: int, details: dict = None):
    safe_details = {k: _serialize_value(v) for k, v in (details or {}).items()}

    log_entry = {
        "jobassign_id": jobassign_id,
        "event": event,
        "changed_by": changed_by,
        "timestamp": datetime.now(timezone.utc),
        "details": safe_details,
    }
    assignment_logs.insert_one(log_entry)