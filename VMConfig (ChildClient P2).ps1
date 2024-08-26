[string]$userName = 'us\Administrator'
[string]$userPassword = 'SuperSecureDomainPassword12!@'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

If($env:USERDOMAIN -ne "us")
{
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
Add-Computer -DomainName us.lab.local -Credential $credObject -Restart -Force
}

Else{Write-Host "System is already on the domain." | Out-Null}