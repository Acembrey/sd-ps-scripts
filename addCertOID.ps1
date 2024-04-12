$regPath = "Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\FVE"
$propertyName = "CertificateOID"
$propertyValue = ""
$propertyType = "String"

$exists = Get-ItemProperty $regPath -Name $propertyName

if($exists){
    Write-Host ""
    Write-Host -f Red "Property already exists"
    $exists
} else {
    New-ItemProperty -Path $regPath -PropertyType $propertyType -Name $propertyName -Value $propertyValue | Out-Null
    Write-Host ""
    Write-Host -f Blue "Property has been created"
    $exists
}
