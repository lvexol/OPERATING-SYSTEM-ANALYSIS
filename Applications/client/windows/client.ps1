<#
.SYNOPSIS
    Windows Telemetry Client for Operating System Analysis Project
.DESCRIPTION
    Collects system metrics and sends them to a central server.
    Equivalent to the Linux client.sh script.
#>

# Configuration
$ServerUrl = "http://localhost:8000"
$Interval = 60 # seconds
$AgentIdFile = "agent_id.txt"
$Debug = $false

# Ensure we are in the script's directory for relative paths
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# --- Helper Functions ---

function Get-AgentId {
    if (Test-Path $AgentIdFile) {
        Get-Content $AgentIdFile -Raw
    } else {
        $NewId = [guid]::NewGuid().ToString()
        $NewId | Out-File $AgentIdFile -NoNewline -Encoding utf8
        $NewId
    }
}

function Get-SystemInfo {
    $OS = Get-CimInstance Win32_OperatingSystem
    $ComputerSystem = Get-CimInstance Win32_ComputerSystem
    
    # Calculate uptime
    $LastBoot = $OS.LastBootUpTime
    $Uptime = (Get-Date) - $LastBoot
    $BootTimeTimestamp = [int][double]::Parse((Get-Date -Date $LastBoot -UFormat %s))
    
    @{
        hostname = $env:COMPUTERNAME
        os_name = $OS.Caption.Trim()
        os_version = $OS.Version
        kernel_version = $OS.BuildNumber # Closest Windows equivalent
        cpu_arch = $OS.OSArchitecture
        uptime_seconds = [math]::Round($Uptime.TotalSeconds)
        boot_time_timestamp = $BootTimeTimestamp
    }
}

function Get-CpuInfo {
    $Cpu = Get-CimInstance Win32_Processor
    # Get load percentage. Note: LoadPercentage is instantaneous and might not be accurate.
    # A better way is strictly using performance counters, but Win32_Processor is simpler and standard.
    # We will use LoadPercentage for simplicity to match the "snapshot" nature.
    
    @{
        model = $Cpu.Name.Trim()
        cores = $Cpu.NumberOfLogicalProcessors
        usage_percent = $Cpu.LoadPercentage
    }
}

function Get-MemoryInfo {
    $OS = Get-CimInstance Win32_OperatingSystem
    $Total = $OS.TotalVisibleMemorySize * 1KB
    $Available = $OS.FreePhysicalMemory * 1KB
    $Used = $Total - $Available
    $Percent = [math]::Round(($Used / $Total) * 100)

    @{
        total_bytes = $Total
        available_bytes = $Available
        used_percent = $Percent
    }
}

function Get-DiskInfo {
    $Disks = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
    $DiskList = @()
    
    foreach ($Disk in $Disks) {
        $Total = $Disk.Used + $Disk.Free
        if ($Total -gt 0) {
            $Percent = [math]::Round(($Disk.Used / $Total) * 100)
            $DiskList += @{
                device = $Disk.Name
                mountpoint = $Disk.Root
                total_bytes = $Total
                used_bytes = $Disk.Used
                percent = $Percent
            }
        }
    }
    
    $DiskList
}

function Get-NetworkInterfaces {
    $Nics = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" }
    $NicList = @()
    
    foreach ($Nic in $Nics) {
        $IpConfig = Get-NetIPAddress -InterfaceAlias $Nic.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $Ip = if ($IpConfig) { $IpConfig.IPAddress } else { $null }
        
        $NicList += @{
            name = $Nic.Name
            ip_address = $Ip
            mac_address = $Nic.MacAddress
            is_up = $true
        }
    }
    
    $NicList
}

function Get-ProcessInfo {
    # Get top 20 processes by CPU/Memory. 
    # PowerShell Get-Process returns all, we sort and take top 20 to mimic client.sh behavior
    $Procs = Get-Process | Sort-Object CPU -Descending -ErrorAction SilentlyContinue | Select-Object -First 20
    $ProcList = @()
    
    foreach ($Proc in $Procs) {
        $ProcList += @{
            pid = $Proc.Id
            name = $Proc.ProcessName
            username = $Proc.UserName # May require elevation
            status = if ($Proc.Responding) { "Running" } else { "Not Responding" }
        }
    }
    
    $ProcList
}

function Get-SecurityInfo {
    # Users
    $Users = Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }
    $UserList = @()
    foreach ($User in $Users) {
        $UserList += @{
            name = $User.Name
            uid = $User.SID # Windows uses SIDs, not specific UIDs
            gid = $null     # Not applicable in same way
            shell = "N/A"
        }
    }
    
    # Open Ports
    $Ports = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LocalPort -Unique | Sort-Object
    if (-not $Ports) { $Ports = @() }

    @{
        users = $UserList
        security = @{
            open_ports = $Ports
            firewall_active = (Get-NetFirewallProfile -Profile Domain,Public,Private | Where-Object {$_.Enabled}).Count -gt 0
        }
    }
}

# --- Main Execution ---

$AgentId = Get-AgentId
Write-Host "Starting PowerShell Client Agent ID: $AgentId"
Write-Host "Server: $ServerUrl"

while ($true) {
    Write-Host "Collecting data..."
    $Timestamp = [double]::Parse((Get-Date -UFormat %s))

    # Collect all data
    $SystemInfo = Get-SystemInfo
    $CpuInfo = Get-CpuInfo
    $MemInfo = Get-MemoryInfo
    $DiskInfo = Get-DiskInfo
    $NetInfo = Get-NetworkInterfaces
    $ProcInfo = Get-ProcessInfo
    $SecInfo = Get-SecurityInfo

    # Construct Payload
    $Payload = [ordered]@{
        agent_id = $AgentId
        timestamp = $Timestamp
        system = $SystemInfo
        cpu = $CpuInfo
        memory = $MemInfo
        disks = $DiskInfo
        network_interfaces = $NetInfo
        processes = $ProcInfo
        users = $SecInfo.users
        security = $SecInfo.security
    }

    $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress
    
    if ($Debug) {
        Write-Host "DEBUG Payload:"
        Write-Host $JsonPayload
    }

    Write-Host "Sending data..."
    
    try {
        $Response = Invoke-RestMethod -Uri "$ServerUrl/api/v1/telemetry" -Method Post -Body $JsonPayload -ContentType "application/json" -ErrorAction Stop
        Write-Host "Data sent successfully."
    } catch {
        Write-Host "Failed to send data: $_"
    }
    
    Start-Sleep -Seconds $Interval
}
