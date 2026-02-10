from pydantic import BaseModel
from typing import List, Optional, Dict

# --- Sub-Models ---

class SystemInfo(BaseModel):
    hostname: str
    os_name: str
    os_version: str
    kernel_version: str
    cpu_arch: str
    uptime_seconds: float
    boot_time_timestamp: float

class CPUInfo(BaseModel):
    model: str
    cores: int
    usage_percent: float

class MemoryInfo(BaseModel):
    total_bytes: int
    available_bytes: int
    used_percent: float

class DiskInfo(BaseModel):
    device: str
    mountpoint: str
    total_bytes: int
    used_bytes: int
    percent: float

class ProcessInfo(BaseModel):
    pid: int
    name: str
    username: str
    status: str

class NetworkInterface(BaseModel):
    name: str
    ip_address: Optional[str] = None
    mac_address: Optional[str] = None
    is_up: bool

class NetworkConnection(BaseModel):
    fd: int
    family: int
    type: int
    laddr: tuple
    raddr: Optional[tuple] = None
    status: str
    pid: Optional[int] = None

class UserInfo(BaseModel):
    name: str
    uid: int
    gid: int
    shell: str

class SecurityInfo(BaseModel):
    open_ports: List[int]
    # Simple boolean flags or lists for now
    firewall_active: bool = False
    
# --- Main Telemetry Payload ---

class TelemetryPayload(BaseModel):
    agent_id: str
    job_id: Optional[str] = None
    timestamp: float
    
    system: SystemInfo
    cpu: CPUInfo
    memory: MemoryInfo
    disks: List[DiskInfo]
    processes: List[ProcessInfo]
    network_interfaces: List[NetworkInterface]
    # network_connections: List[NetworkConnection] # Can be heavy, maybe optional
    users: List[UserInfo]
    security: SecurityInfo
