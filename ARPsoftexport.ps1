$data = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$data| Export-Csv C:\Temp\ARPSoftware.csv -NoTypeInformation | Format-Table
