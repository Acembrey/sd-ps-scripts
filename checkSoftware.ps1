#This barely a script, but obviously typing out the the full command is a pain. 

$computername = Read-host -Prompt 'Input computer name' #Prompt User to enter a computer name

Invoke-Command -ComputerName $computername -ScriptBlock 
{ 
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\Currentversion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion | Sort-Object -Property DisplayName | Format-Table -AutoSize
} 

