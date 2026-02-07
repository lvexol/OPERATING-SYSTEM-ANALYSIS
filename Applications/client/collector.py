import time
import uuid
import os
from models import TelemetryPayload
from modules import system, hardware, network, process, security

class Collector:
    def __init__(self, agent_id: str):
        self.agent_id = agent_id

    def collect(self) -> TelemetryPayload:
        return TelemetryPayload(
            agent_id=self.agent_id,
            timestamp=time.time(),
            system=system.get_system_info(),
            cpu=hardware.get_cpu_info(),
            memory=hardware.get_memory_info(),
            disks=hardware.get_disk_info(),
            processes=process.get_process_info(),
            network_interfaces=network.get_network_interfaces(),
            users=security.get_users(),
            security=security.get_security_info()
        )
