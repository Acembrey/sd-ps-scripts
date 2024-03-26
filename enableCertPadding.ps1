$regPath = "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config"
$regPath64 = "HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config"
$property = "EnableCertPaddingCheck"
$value = "1"

if((test-path $regPath) -eq $false)
{
New-Item "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "Winrust"
New-Item "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust" -Name "Config"
New-ItemProperty -Path $path -Name $name -Value $value
}else
{
Write-Host -f Green "86x Keys Already Exist"
}


if((Test-Path $regPath64) -eq $false)
{
New-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Cryptography" -Name "Wintrust"
New-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Cryptography\Wintrust" -Name "Config"
New-ItemProperty -Path $path64 -Name $name -Value $value
}else
{
Write-Host -f Green "64x Keys Already Exist"
}
