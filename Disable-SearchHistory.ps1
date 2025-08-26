# Disable device search history and log changes
$ErrorActionPreference = 'Stop'
$LogFile = "C:\Logs\SearchHistoryDisable.log"

# Ensure log directory exists
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

function Write-Log {
    param([string]$Message)
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$Timestamp - $Message"
}

try {
    # Registry path & name
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
    $RegName = "IsDeviceSearchHistoryEnabled"

    # Ensure the key exists
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

    # Set the value to 0 (disabled) - use Set-ItemProperty so it works whether it exists or not
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 0 -Type DWord

    # Read back reliably
    $prop = Get-ItemProperty -Path $RegPath -Name $RegName
    [int]$Status = $prop.$RegName  # force to int for clean logging

    Write-Log "Successfully set $RegName to $Status at $RegPath"
    Write-Output "Successfully set $RegName to $Status at $RegPath"
}
catch {
    Write-Log "ERROR: Failed to update registry. $($_.Exception.Message)"
    Write-Error $_
}
