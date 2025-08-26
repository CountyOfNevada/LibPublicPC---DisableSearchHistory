$ErrorActionPreference = 'Stop'
$LogFile = "C:\Logs\SearchHistoryDisable.log"
$UserName = "Public"
$UserProfilePath = "C:\Users\$UserName"
$HiveFile = Join-Path $UserProfilePath "NTUSER.DAT"
$MountPoint = "HKU\Temp_$UserName"
$RegRelPath = "Software\Microsoft\Windows\CurrentVersion\SearchSettings"
$RegName = "IsDeviceSearchHistoryEnabled"

function Write-Log([string]$msg) {
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$ts - $msg"
}

Write-Log "==== Setting Search History for $UserName ===="

if (-not (Test-Path $HiveFile)) {
    Write-Log "ERROR: NTUSER.DAT not found at $HiveFile"
    exit
}

try {
    # Load the hive into HKU if not already mounted
    reg load $MountPoint $HiveFile | Out-Null
    Write-Log "Loaded hive for $UserName at $MountPoint"

    $RegPath = "Registry::$MountPoint\$RegRelPath"
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

    # Set value to 0 (disable)
    Set-ItemProperty -Path $RegPath -Name $RegName -Type DWord -Value 0
    $val = (Get-ItemProperty -Path $RegPath -Name $RegName).$RegName

    Write-Log "Set $RegName for $UserName to $val"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
}
finally {
    reg unload $MountPoint | Out-Null
    Write-Log "Unloaded hive for $UserName"
    Write-Log "==== Finished ===="
}
