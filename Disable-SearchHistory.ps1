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
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDeviceSearchHistoryEnabled" -Value 0 -PropertyType DWord -Force 

    $Status = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDeviceSearchHistoryEnabled"

    Write-Log "Successfully set $RegName to $Status at $RegPath"
}
catch {
    Write-Log "ERROR: Failed to update registry. $_"
}
