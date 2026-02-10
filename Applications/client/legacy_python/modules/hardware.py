import psutil
from typing import List
from models import CPUInfo, MemoryInfo, DiskInfo

def get_cpu_info() -> CPUInfo:
    # Note: cpu_percent needs a blocking call or interval to be accurate usually. 
    # For a snapshot, we might accept 0.0 or use a small interval.
    # We'll use 0.1s interval which is minimal but gives a reading.
    return CPUInfo(
        model="Detected via /proc/cpuinfo or similar", # psutil doesn't give model name easily x-plat
        cores=psutil.cpu_count(logical=True),
        usage_percent=psutil.cpu_percent(interval=0.1)
    )

def get_memory_info() -> MemoryInfo:
    mem = psutil.virtual_memory()
    return MemoryInfo(
        total_bytes=mem.total,
        available_bytes=mem.available,
        used_percent=mem.percent
    )

def get_disk_info() -> List[DiskInfo]:
    disks = []
    for part in psutil.disk_partitions():
        try:
            usage = psutil.disk_usage(part.mountpoint)
            disks.append(DiskInfo(
                device=part.device,
                mountpoint=part.mountpoint,
                total_bytes=usage.total,
                used_bytes=usage.used,
                percent=usage.percent
            ))
        except PermissionError:
            continue
    return disks
