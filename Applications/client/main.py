import os
import time
import uuid
import argparse
from collector import Collector
from transport import Transport

AGENT_ID_FILE = "agent_id.txt"
DEFAULT_SERVER_URL = "http://localhost:8000"
INTERVAL = 60 # seconds

def get_agent_id():
    if os.path.exists(AGENT_ID_FILE):
        with open(AGENT_ID_FILE, "r") as f:
            return f.read().strip()
    else:
        aid = str(uuid.uuid4())
        with open(AGENT_ID_FILE, "w") as f:
            f.write(aid)
        return aid

def main():
    parser = argparse.ArgumentParser(description="Linux Telemetry Agent")
    parser.add_argument("--server", default=DEFAULT_SERVER_URL, help="Server URL")
    parser.add_argument("--interval", type=int, default=INTERVAL, help="Collection interval (s)")
    args = parser.parse_args()

    agent_id = get_agent_id()
    print(f"Starting Agent with ID: {agent_id}")
    print(f"Server: {args.server}")

    collector = Collector(agent_id)
    transport = Transport(args.server)

    while True:
        print("Collecting data...")
        payload = collector.collect()
        
        print(f"Sending data (Processes: {len(payload.processes)})...")
        success = transport.send_telemetry(payload)
        
        if success:
            print("Data sent successfully.")
        else:
            print("Failed to send data.")
            
        time.sleep(args.interval)

if __name__ == "__main__":
    main()
