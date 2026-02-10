import platform
import time
import psutil
from models import SystemInfo

def get_system_info() -> SystemInfo:
    return SystemInfo(
        hostname=platform.node(),
        os_name=platform.system(),
        os_version=platform.release(),
        kernel_version=platform.version(),
        cpu_arch=platform.machine(),
        uptime_seconds=time.time() - psutil.boot_time(),
        boot_time_timestamp=psutil.boot_time()
    )
