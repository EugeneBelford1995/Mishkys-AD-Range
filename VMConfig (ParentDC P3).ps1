$ADRoot = (Get-ADDomain).DistinguishedName
$FQDN = (Get-ADDomain).DNSRoot

#Store a password for users
[string]$DSRMPassword = 'SuperSecureDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$UserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

$User = "Break.Glass"

New-ADUser -SamAccountName $User -Name $User -UserPrincipalName "$User@$FQDN" -AccountPassword $UserPassword -Enabled $true -Description "Backup Ent Admin" -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Enterprise Admins" -Members "$User"
Add-ADGroupMember -Identity "Domain Admins" -Members "$User"
Add-ADGroupMember -Identity "Schema Admins" -Members "$User"
Add-ADGroupMember -Identity "Administrators" -Members "$User"