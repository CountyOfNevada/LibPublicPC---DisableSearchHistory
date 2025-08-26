# Disable device search history and log changes
$ErrorActionPreference = 'Stop'
$LogFile = "C:\Logs\SearchHistoryDisable.log"

# Ensure log directory exists
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

function Write-Log([string]$msg) {
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$ts - $msg"
}

Write-Log "==== Script started ===="

# Log current user context
$me = [Security.Principal.WindowsIdentity]::GetCurrent()
Write-Log "Running as: $($me.Name), SID: $($me.User.Value)"

# Log all local users on the machine
try {
    $users = Get-LocalUser | Select-Object Name, Enabled, LastLogon
    Write-Log "Local Users on this machine:"
    foreach ($u in $users) {
        Write-Log ("   Name: {0}, Enabled: {1}, LastLogon: {2}" -f $u.Name, $u.Enabled, $u.LastLogon)
    }
} catch {
    Write-Log "ERROR: Failed to enumerate local users. $($_.Exception.Message)"
}

# Registry path & name
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
$RegName = "IsDeviceSearchHistoryEnabled"

try {
    # Ensure the key exists
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

    # Set the value to 0 (disabled)
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 0 -Type DWord

    # Verify
    $prop = Get-ItemProperty -Path $RegPath -Name $RegName
    [int]$Status = $prop.$RegName

    Write-Log "Successfully set $RegName to $Status at $RegPath"
    Write-Output "Successfully set $RegName to $Status at $RegPath"
}
catch {
    Write-Log "ERROR: Failed to update registry. $($_.Exception.Message)"
}

Write-Log "==== Script finished ===="
