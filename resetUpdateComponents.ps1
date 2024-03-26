# Stop Windows Update services
Stop-Service -Name wuauserv -Force -Wait
Stop-Service -Name CryptSvc -Force -Wait
Stop-Service -Name bits -Force -Wait
Stop-Service -Name msiserver -Force -Wait

# Rename SoftwareDistribution and catroot2 folders
Rename-Item -Path "$env:SystemRoot\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
Rename-Item -Path "$env:SystemRoot\System32\catroot2" -NewName "catroot2.old" -Force

# Restart Windows Update services
Start-Service -Name wuauserv -Wait
Start-Service -Name CryptSvc -Wait
Start-Service -Name bits -Wait
Start-Service -Name msiserver -Wait

# Reset Windows Update components
$wu = New-Object -ComObject Microsoft.Update.ServiceManager
$wu.Client = New-Object -ComObject Microsoft.Update.ServiceManager
$wu.Client.FullReset()

Write-Host "Windows Update components have been reset successfully."
