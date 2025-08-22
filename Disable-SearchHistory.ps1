# Create the SearchSettings key if it doesn't exist
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion" -Name "SearchSettings" -Force

# Add or set the DWORD IsDeviceSearchHistoryEnabled = 0
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" `
  -Name "IsDeviceSearchHistoryEnabled" `
  -PropertyType DWord `
  -Value 0 -Force
