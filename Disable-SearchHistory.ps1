# Disable device search history and log changes (HKCU)
$LogFile = "C:\Logs\SearchHistoryDisable.log"
$KeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
$ValueName = "IsDeviceSearchHistoryEnabled"
$Desired = 0

# Ensure logging folder exists
$null = New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force -ErrorAction SilentlyContinue

function Write-Log {
    param([string]$Message)
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$Timestamp - $Message"
}

try {
    $ErrorActionPreference = 'Stop'

    # Ensure the key exists
    if (-not (Test-Path $KeyPath)) {
        New-Item -Path $KeyPath -Force | Out-Null
        Write-Log "Created registry key: $KeyPath"
    }

    # Set the value (use Set-ItemProperty to avoid ambiguity)
    Set-ItemProperty -Path $KeyPath -Name $ValueName -Type DWord -Value $Desired

    # Read back the value explicitly from the property bag
    $propBag = Get-ItemProperty -Path $KeyPath -Name $ValueName
    $Status = [int]$propBag.$ValueName  # cast for clarity

    # Log with subexpression to force visible stringification
    Write-Log ("Successfully set {0} to {1} at {2}" -f $ValueName, $Status, $KeyPath)

    # Optional: also echo to console for immediate visibility
    Write-Output ("{0}: {1}" -f $ValueName, $Status)
}
catch {
    Write-Log "ERROR: Failed to update registry. $($_.Exception.Message)"
}
