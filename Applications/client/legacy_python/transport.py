import requests
import json
from models import TelemetryPayload

class Transport:
    def __init__(self, server_url: str):
        self.server_url = server_url.rstrip('/')
        self.endpoint = f"{self.server_url}/api/v1/telemetry"

    def send_telemetry(self, payload: TelemetryPayload) -> bool:
        try:
            # We use payload.json() (pydantic v1) or model_dump_json (v2)
            # Assuming recent pydantic, usually .json() or .dict() works.
            # Using .dict() and ensuring json serialization via requests is safest compatibility-wise
            response = requests.post(self.endpoint, json=payload.dict())
            response.raise_for_status()
            return True
        except Exception as e:
            print(f"Error sending telemetry: {e}")
            return False
