import psutil
import socket
from typing import List
from models import NetworkInterface, NetworkConnection

def get_network_interfaces() -> List[NetworkInterface]:
    interfaces = []
    addrs = psutil.net_if_addrs()
    stats = psutil.net_if_stats()
    
    for nic, snics in addrs.items():
        is_up = stats[nic].isup if nic in stats else False
        ipv4 = None
        mac = None
        
        for snic in snics:
            if snic.family == socket.AF_INET:
                ipv4 = snic.address
            elif snic.family == psutil.AF_LINK:
                mac = snic.address
                
        interfaces.append(NetworkInterface(
            name=nic,
            ip_address=ipv4,
            mac_address=mac,
            is_up=is_up
        ))
    return interfaces

# Note: getting connections might be heavy and require sudo for all.
# We will skip get_network_connections for the main payload to keep it light
# or implement it if part of security.
