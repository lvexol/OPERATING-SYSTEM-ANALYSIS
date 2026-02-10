#!/bin/bash

# Configuration
SERVER_URL="http://localhost:8000"
INTERVAL=60 # seconds
AGENT_ID_FILE="agent_id.txt"

# Ensure dependencies
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Aborting."; exit 1; }

# --- Helper Functions ---

# Generate or retrieve Agent ID
get_agent_id() {
    if [ -f "$AGENT_ID_FILE" ]; then
        cat "$AGENT_ID_FILE"
    else
        # Generate a distinct ID (uuidgen if available, else date+random)
        if command -v uuidgen >/dev/null 2>&1; then
            uuidgen
        else
            echo "$(date +%s)-$(od -x /dev/urandom | head -1 | awk '{print $2$3}')"
        fi | tee "$AGENT_ID_FILE"
    fi
}

# 0. Distro Info
get_distro_info() {
    local distro_name="Unknown"
    local distro_version="Unknown"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro_name="${NAME:-Unknown}"
        distro_version="${VERSION_ID:-Unknown}"
    elif command -v lsb_release >/dev/null 2>&1; then
        distro_name=$(lsb_release -si)
        distro_version=$(lsb_release -sr)
    fi
    
    # Sanitize quotes
    distro_name=${distro_name//\"/\\\"}
    distro_version=${distro_version//\"/\\\"}
     
    echo "\"os_name\": \"$distro_name\", \"os_version\": \"$distro_version\""
}

# 1. System Info
get_system_info() {
    local hostname=$(hostname)
    local os_name=$(uname -s)
    local os_version=$(uname -r)
    local kernel_version=$(uname -v)
    local cpu_arch=$(uname -m)
    
    # Calculate uptime and boot time
    local uptime_seconds=$(cat /proc/uptime | awk '{print $1}')
    local now=$(date +%s)
    local boot_time=$(echo "$now - $uptime_seconds" | bc 2>/dev/null || awk -v n="$now" -v u="$uptime_seconds" 'BEGIN {print n - u}')
    
    cat <<EOF
"system": {
    "hostname": "$hostname",
    "os_name": "$os_name",
    "os_version": "$os_version",
    "kernel_version": "$kernel_version",
    "cpu_arch": "$cpu_arch",
    "uptime_seconds": $uptime_seconds,
    "boot_time_timestamp": $boot_time
}
EOF
}

# 2. CPU Info
get_cpu_info() {
    # Try to get model name
    local model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
    [ -z "$model" ] && model="Unknown"
    
    local cores=$(grep -c ^processor /proc/cpuinfo)
    
    # Simple CPU usage calculation using /proc/stat
    # Check 1
    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
    local total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local idle1=$((idle + iowait))
    
    sleep 0.1
    
    # Check 2
    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
    local total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local idle2=$((idle + iowait))
    
    local total_diff=$((total2 - total1))
    local idle_diff=$((idle2 - idle1))
    # Avoid division by zero
    [ "$total_diff" -eq 0 ] && total_diff=1
    
    # Calculate usage percentage (integer approximation)
    local usage=$((100 * (total_diff - idle_diff) / total_diff))

    cat <<EOF
"cpu": {
    "model": "$model",
    "cores": $cores,
    "usage_percent": $usage
}
EOF
}

# 3. Memory Info
get_memory_info() {
    # Read /proc/meminfo for accuracy
    local total=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')
    local available=$(grep MemAvailable /proc/meminfo | awk '{print $2 * 1024}')
    
    # If MemAvailable is missing (older kernels), approximate with free + buffers + cached
    if [ -z "$available" ]; then
        local free=$(grep MemFree /proc/meminfo | awk '{print $2 * 1024}')
        local buffers=$(grep Buffers /proc/meminfo | awk '{print $2 * 1024}')
        local cached=$(grep ^Cached /proc/meminfo | awk '{print $2 * 1024}')
        available=$((free + buffers + cached))
    fi
    
    local used=$((total - available))
    local percent=$((100 * used / total))
    
    cat <<EOF
"memory": {
    "total_bytes": $total,
    "available_bytes": $available,
    "used_percent": $percent
}
EOF
}

# 4. Disk Info (Root only for simplicity, as per Python script iterating partitions is complex in shell)
get_disk_info() {
    # Get usage for various mount points. Here we focus on standard partitions.
    # Parsing df output to JSON array
    local disks_json=""
    
    # Loop over df output, skipping header, taking only physical filesystems usually
    while read -r fs blocks used _available percent mount; do
        # Cleanup percent (remove %)
        percent=${percent%\%}
        # Cleanup usage (blocks to bytes, usually 1K blocks)
        local total=$((blocks * 1024))
        local used_bytes=$((used * 1024))
        
        # Construct JSON object for this disk
        local disk_obj="{\"device\": \"$fs\", \"mountpoint\": \"$mount\", \"total_bytes\": $total, \"used_bytes\": $used_bytes, \"percent\": $percent}"
        
        if [ -z "$disks_json" ]; then
            disks_json="$disk_obj"
        else
            disks_json="$disks_json, $disk_obj"
        fi
    done < <(df -P -k -x tmpfs -x devtmpfs -x squashfs | tail -n +2)
    
    echo "\"disks\": [$disks_json]"
}

# 5. Network Info
get_network_interfaces() {
    local nics_json=""
    
    for iface in /sys/class/net/*; do
        local name=$(basename "$iface")
        # Skip loopback if desired, or keep it. The python script kept everything.
        
        local ip_addr=""
        # Try to get IP via 'ip' command if available
        if command -v ip >/dev/null 2>&1; then
            ip_addr=$(ip -4 addr show "$name" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        fi
        
        local mac=$(cat "$iface/address" 2>/dev/null)
        local operstate=$(cat "$iface/operstate" 2>/dev/null)
        local is_up="false"
        [ "$operstate" == "up" ] && is_up="true"
        
        [ -z "$ip_addr" ] && ip_addr="null" || ip_addr="\"$ip_addr\""
        [ -z "$mac" ] && mac="null" || mac="\"$mac\""
        
        local nic_obj="{\"name\": \"$name\", \"ip_address\": $ip_addr, \"mac_address\": $mac, \"is_up\": $is_up}"
        
         if [ -z "$nics_json" ]; then
            nics_json="$nic_obj"
        else
            nics_json="$nics_json, $nic_obj"
        fi
    done
    
    echo "\"network_interfaces\": [$nics_json]"
}

# 6. Process Info
get_process_info() {
    # Listing top 20 processes to avoid gigantic JSON payload
    local procs_json=""
    
    # ps output: pid, comm (name), user, s (state)
    # Using 'comm' for name to avoid spaces issues, or just handle it carefully.
    while read -r pid user state cmd; do
        # JSON escape command: escape backslashes first, then quotes
        cmd=$(echo "$cmd" | sed 's/\\/\\\\/g; s/"/\\"/g')
        
        local proc_obj="{\"pid\": $pid, \"name\": \"$cmd\", \"username\": \"$user\", \"status\": \"$state\"}"
        
         if [ -z "$procs_json" ]; then
            procs_json="$proc_obj"
        else
            procs_json="$procs_json, $proc_obj"
        fi
    done < <(ps -eo pid,user,state,comm --no-headers)
    
    echo "\"processes\": [$procs_json]"

}

# 7. Security Info (Users and Ports)
get_security_info() {
    # Users
    local users_json=""
    # Use 'who' or '/etc/passwd' iteration. 'who' shows logged in users.
    # The python script used pwd.getpwall() filtering UID>=1000.
    
    # Let's read /etc/passwd
    while IFS=: read -r user pass uid gid comment home shell; do
        if [ "$uid" -ge 1000 ] || [ "$uid" -eq 0 ]; then
             local user_obj="{\"name\": \"$user\", \"uid\": $uid, \"gid\": $gid, \"shell\": \"$shell\"}"
             if [ -z "$users_json" ]; then
                users_json="$user_obj"
            else
                users_json="$users_json, $user_obj"
            fi
        fi
    done < /etc/passwd
    
    # Open Ports
    local ports_json=""
    # Try ss or netstat
    if command -v ss >/dev/null 2>&1; then
        ports=$(ss -tuln | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -nu | tr '\n' ' ')
    elif command -v netstat >/dev/null 2>&1; then
        ports=$(netstat -tuln | awk 'NR>2 {print $4}' | awk -F: '{print $NF}' | sort -nu | tr '\n' ' ')
    fi
    
    # Format ports list [80, 22, ...]
    for p in $ports; do
        if [ -z "$ports_json" ]; then ports_json="$p"; else ports_json="$ports_json, $p"; fi
    done
    [ -z "$ports_json" ] && ports_json="" 
    
    # Construct Security Object
    cat <<EOF
"users": [$users_json],
"security": {
    "open_ports": [$ports_json],
    "firewall_active": false
}
EOF
}

# --- Main Execution ---

AGENT_ID=$(get_agent_id)
echo "Starting Shell Client Agent ID: $AGENT_ID"
echo "Server: $SERVER_URL"

while true; do
    echo "Collecting data..."
    timestamp=$(date +%s.%N)
    
    # Build JSON Payload
    # Note: We are manually constructing JSON. It's fragile but standard tools (jq) might not be everywhere.
    # If jq is allowed, it's safer. Assuming manual for lowest common denominator.
    
    json_payload="{"
    json_payload+="$(get_distro_info),"
    json_payload+="\"agent_id\": \"$AGENT_ID\","
    json_payload+="\"timestamp\": $timestamp,"
    json_payload+="$(get_system_info),"
    json_payload+="$(get_cpu_info),"
    json_payload+="$(get_memory_info),"
    json_payload+="$(get_disk_info),"
    json_payload+="$(get_network_interfaces),"
    json_payload+="$(get_process_info),"
    json_payload+="$(get_security_info)"
    json_payload+="}"
    
    
    # Validate JSON (optional, if jq exists)
    if command -v jq >/dev/null 2>&1; then
        if ! echo "$json_payload" | jq . >/dev/null 2>&1; then
            echo "Error: Constructed JSON is invalid."
            # Debug: echo "$json_payload"
        fi
    fi

    if [ "$DEBUG" = "1" ]; then
        echo "DEBUG Payload:"
        echo "$json_payload"
    fi

    echo "Sending data..."
    # Send via Curl
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SERVER_URL/api/v1/telemetry" \
        -H "Content-Type: application/json" \
        -d "$json_payload")
        
    if [ "$response" -eq 200 ] || [ "$response" -eq 201 ]; then
        echo "Data sent successfully (HTTP $response)."
    else
        echo "Failed to send data (HTTP $response)."
    fi
    
    sleep $INTERVAL
done
