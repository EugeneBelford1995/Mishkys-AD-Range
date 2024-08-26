#Map the HackMe share drive to Z as The Adminstrator, aka SID 500 on marvel.local
[string]$userName = 'us\Frisky.McRisky'
[string]$userPassword = 'SuperSecretPassword!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$FriskyCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Install-Module -Name CredentialManager -Confirm -Force -SkipPublisherCheck
Start-Sleep -Seconds 60
New-StoredCredential -Comment "Access share drvie on US-DC" -Credentials $FriskyCredObject -Target "US-DC" -Persist Enterprise | Out-Null
#$SharedDriveCredObject = Get-StoredCredential -Target "Marvel-DC" -AsCredentialObject
#New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\Marvel-DC\HackMe" -Credential $DomainAdminCredObject -Persist

#Store a password for DSRM
[string]$DSRMPassword = 'SuperSecretPassword!'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Add-LocalGroupMember -Group "Administrators" -Member "us\Helpdesk Tier I","us\Helpdesk Tier II","us\Server Admins","us\Server Admins T2"
Set-LocalUser -Name Administrator -Password $SecureStringPassword

Restart-Computer -Force