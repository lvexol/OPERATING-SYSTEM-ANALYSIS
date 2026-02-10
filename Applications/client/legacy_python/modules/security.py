import psutil
import pwd
from typing import List
from models import UserInfo, SecurityInfo

def get_users() -> List[UserInfo]:
    users = []
    for user in pwd.getpwall():
        # Filter for normal users (usually UID >= 1000) or root
        if user.pw_uid >= 1000 or user.pw_uid == 0:
            users.append(UserInfo(
                name=user.pw_name,
                uid=user.pw_uid,
                gid=user.pw_gid,
                shell=user.pw_shell
            ))
    return users

def get_security_info() -> SecurityInfo:
    open_ports = []
    try:
        # Requires privs to see all
        connections = psutil.net_connections(kind='inet')
        for conn in connections:
            if conn.status == 'LISTEN':
                open_ports.append(conn.laddr.port)
    except psutil.AccessDenied:
        pass
    
    # Placeholder for firewall check (would need to check systemctl or ufw status)
    # Keeping it simple/safe for now.
    firewall_active = False 
    
    return SecurityInfo(
        open_ports=list(set(open_ports)),
        firewall_active=firewall_active
    )
