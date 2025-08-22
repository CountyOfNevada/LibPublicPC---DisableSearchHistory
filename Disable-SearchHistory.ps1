# Disable device search history
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" `
    -Name "IsDeviceSearchHistoryEnabled" -Value 0 -Type DWord
