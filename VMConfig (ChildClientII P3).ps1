#Store a password for DSRM
[string]$DSRMPassword = 'JoshuaWOPRWarGames1983'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Add-LocalGroupMember -Group "Administrators" -Member "us\Server Admins","us\Server Admins T2"
Set-LocalUser -Name Administrator -Password $SecureStringPassword
Restart-Computer -Force