import psutil
from typing import List
from models import ProcessInfo

def get_process_info() -> List[ProcessInfo]:
    procs = []
    # Iterate over all running processes
    for proc in psutil.process_iter(['pid', 'name', 'username', 'status']):
        try:
            pinfo = proc.info
            procs.append(ProcessInfo(
                pid=pinfo['pid'],
                name=pinfo['name'] or "unknown",
                username=pinfo['username'] or "unknown",
                status=pinfo['status'] or "unknown"
            ))
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return procs
