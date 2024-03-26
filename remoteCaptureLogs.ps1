#The Invoke-Command portion of this command could be removed. Only kept to reduce my typing.
#This script is meant to work around double-hop issues, as I was attempting to store the results to my network share for ease of viewing and tracking. 

$comp = Read-Host "Enter Computer Name"

Invoke-Command -ComputerName $comp -ScriptBlock{

$computerName = $env:COMPUTERNAME
$logFilePath = "C:\Windows\Logs\CBS\CBS.log"
$localFilePath = "C:\$computerName\cbsErrors.txt"
$errors = Get-Content $logFilePath | Where-Object { $_ -match "error" }

New-Item -ItemType Directory "C:\$computerName"
sfc /scannow
$errors | Out-File -FilePath $localFilePath -Force
Write-Host "Error lines have been written to $outputFilePath"

}

$hostFilePath = "C:\$comp"
$remoteFilePath = "\\$comp\C$\$comp"
$networkFilePath = "\\Path\to\network\share"

Copy-Item -Recurse -Path $remoteFilePath -Destination $hostFilePath 
Copy-Item -Path $hostFilePath -Destination $networkFilePath
