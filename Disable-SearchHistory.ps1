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

function Get-UserSid {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        return $id.User.Value
    } catch {
        try {
            $acct = New-Object System.Security.Principal.NTAccount("$env:UserDomain",$env:UserName)
            return ($acct.Translate([System.Security.Principal.SecurityIdentifier])).Value
        } catch { return "<unknown SID>" }
    }
}

# ------- Context logging -------
try {
    $procId   = [Security.Principal.WindowsIdentity]::GetCurrent()
    $who      = $procId.Name
    $user     = $env:USERNAME
    $domain   = $env:USERDOMAIN
    $sid      = Get-UserSid
    $isAdmin  = (New-Object Security.Principal.WindowsPrincipal $procId).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    $arch     = if ([Environment]::Is64BitProcess) { "x64" } else { "x86" }
    $psver    = $PSVersionTable.PSVersion.ToString()
    $hostName = $env:COMPUTERNAME

    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) { $scriptPath = "<interactive or unknown>" }
    $scriptDir  = if ($scriptPath -and $scriptPath -ne "<interactive or unknown>") { Split-Path $scriptPath -Parent } else { "<n/a>" }
    $cwd        = (Get-Location).Path

    Write-Log "----- Context -----"
    Write-Log "WhoAmI: $who"
    Write-Log "Env User: $domain\$user"
    Write-Log "SID: $sid"
    Write-Log "Machine: $hostName | Admin: $isAdmin | ProcArch: $arch | PS:$psver"
    Write-Log "ScriptPath: $scriptPath"
    Write-Log "ScriptDir:  $scriptDir"
    Write-Log "WorkingDir: $cwd"
    Write-Log "-------------------"
} catch {
    Write-Log "WARN: Failed to capture context. $($_.Exception.Message)"
}

try {
    # Registry path & name
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
    $RegName = "IsDeviceSearchHistoryEnabled"

    # Ensure the key exists
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }

    # Set the value to 0 (disabled)
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 0 -Type DWord

    # Read back
    $prop = Get-ItemProperty -Path $RegPath -Name $RegName
    [int]$Status = $prop.$RegName

    # Also log the HKU path that HKCU maps to (handy when using runas)
    $sid = Get-UserSid
    $hkuPath = "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\SearchSettings"

    Write-Log "Successfully set $RegName to $Status at $RegPath (HKU path: $hkuPath)"
    Write-Output "Successfully set $RegName to $Status at $RegPath"
}
catch {
    Write-Log "ERROR: Failed to update registry. $($_.Exception.Message)"
    Write-Error $_
}
