# Disable device search history and log changes
$LogFile = "C:\Logs\SearchHistoryDisable.log"

# Function to write logs
function Write-Log {
    param([string]$Message)
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$Timestamp - $Message"
}

try {
    # Registry path
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
    $RegName = "IsDeviceSearchHistoryEnabled"

    # Disable device search history
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 0 -Type DWord

    Write-Log "Successfully set $RegName to 0 at $RegPath"
}
catch {
    Write-Log "ERROR: Failed to update registry. $_"
}
