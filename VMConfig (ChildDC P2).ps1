netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

#Parent Domain's Enterprise Admin creds
[string]$userName = 'lab\Break.Glass'
[string]$userPassword = 'SuperSecureDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ParentAdminCred = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Store a password for DSRM
[string]$DSRMPassword = 'P@$$w0rd'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Install-ADDSDomain -Credential $ParentAdminCred `
    -NewDomainName "us" `
    -NewDomainNetbiosName "us" `
    -ParentDomainName "lab.local" `
    -InstallDNS:$true `
    -CreateDNSDelegation:$true `
    -DomainMode "WinThreshold" `
    -ReplicationSourceDC "Lab-DC.lab.local" `
    -DatabasePath "C:\Windows\NTDS" `
    -SYSVOLPath "C:\Windows\SYSVOL" `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -Force:$true `
    -SafeModeAdministratorPassword $SecureStringPassword