$ADRoot = (Get-ADDomain).DistinguishedName
$FQDN = (Get-ADDomain).DNSRoot

$OUs = "Clients,User_Accounts,Helpdesk,Server_Admins,AD_Admins,Server_Admins_T2" 
$OUs = $OUs.split(",")
ForEach($OU in $OUs)
{
New-ADOrganizationalUnit -Name "$OU" -Path "$ADRoot"
}

# --- Create the users specified in the CSV ---

$Users = Import-Csv -Path "C:\Users.csv"
ForEach($User in $Users)
{
$SamAccountName = $User.FirstName + '.' + $User.LastName
$UPN = $SamAccountName + '@' + $FQDN
$DisplayName = $User.FirstName + ' ' + $User.LastName
$Password = (ConvertTo-SecureString $User.Password -AsPlainText -Force)
$Description = $User.Description
$OU = $User.OU
$Path = "ou=$OU,$ADRoot"

New-ADUser -Name $DisplayName -GivenName $User.FirstName -Surname $User.LastName -DisplayName $DisplayName -Path $Path -SamAccountName $SamAccountName -UserPrincipalName $UPN -AccountPassword $Password -Enabled $true -Description $Description
}

#Create the groups
New-ADGroup "Helpdesk Tier I" -GroupScope Universal -GroupCategory Security -Path "ou=helpdesk,$ADRoot"
New-ADGroup "Helpdesk Tier II" -GroupScope Universal -GroupCategory Security -Path "ou=helpdesk,$ADRoot"
New-ADGroup "Server Admins" -GroupScope Universal -GroupCategory Security -Path "ou=Server_Admins,$ADRoot"
New-ADGroup "AD Admins" -GroupScope Universal -GroupCategory Security -Path "ou=AD_Admins,$ADRoot"
New-ADGroup "Server Admins T2" -GroupScope Universal -GroupCategory Security -Path "ou=Server_Admins_T2,$ADRoot"

$UsersToAdd = (Get-ADUser -Filter * -SearchBase "ou=helpdesk,$ADRoot").SamAccountName
ForEach($UserToAdd in $UsersToAdd)
{Add-ADGroupMember -Identity "Helpdesk Tier I" -Members $UserToAdd}

Add-ADGroupMember -Identity "Helpdesk Tier II" -Members "Frisky.McRisky"
Add-ADGroupMember -Identity "Server Admins T2" -Members "Stephen.Falken"
$UsersToAdd2 = (Get-ADUser -Filter * -SearchBase "ou=Server_Admins,$ADRoot").SamAccountName
ForEach($UserToAdd2 in $UsersToAdd2)
{Add-ADGroupMember -Identity "Server Admins" -Members $UserToAdd2}

Set-ADUser "Jen.Barber" -ChangePasswordAtLogon $true

New-ADComputer -Name "US-Client" -SAMAccountName "US-Client" -DisplayName "US-Client" -Path "ou=clients,$ADRoot"
New-ADComputer -Name "US-ClientII" -SAMAccountName "US-ClientII" -DisplayName "US-ClientII" -Path "ou=clients,$ADRoot"

#Store a password for users
[string]$DSRMPassword = 'SuperSecureDomainPassword12!@'
# Convert to SecureString
[securestring]$UserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

$BackupAdmin = "Break.Glass"

New-ADUser -SamAccountName $BackupAdmin -Name $BackupAdmin -UserPrincipalName "$BackupAdmin@$FQDN" -AccountPassword $UserPassword -Enabled $true -Description "Backup Domain Admin" -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Domain Admins" -Members $BackupAdmin
