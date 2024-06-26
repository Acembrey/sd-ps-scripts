#Variables
$registryKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$keyProperty = "WUServer"
$propertyValue = "Full FQDN to Update Server"

# test to see if the path exists
if (Test-Path $registryKey) {
    # create a variable that gets the properties of the key
    $updateProperties = Get-ItemProperty -Path $registryKey

    # check if the property exists
    if ($updateProperties.PSObject.Properties.Name -contains $keyProperty) {
        # retrieve the value of the property
        $actualPValue = $updateProperties.$keyProperty

        # compare the actual value of to the expected value of the property
        if ($actualPValue -eq $propertyValue) {
            Write-Host "True"
        } else {
            Write-Host "False"
        }
    } else {
        Write-Host "Property '$keyProperty' does not exist in the registry key."
    }
} else {
    Write-Host "Registry Key not found: $registryKey"
}
