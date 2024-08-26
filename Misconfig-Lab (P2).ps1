#Delegate Frisky's Tier II Helpdesk group Extended Rights over the Server Admins OU (student is expected to reset a Server Admin's password)
Import-Module ActiveDirectory
Set-Location AD:
$ADRoot = (Get-ADDomain).DistinguishedName

#Give Helpdesk Tier II Reset Password & Re-enable rights on the Server_Admins & User_Accounts OUs (simulate a sloppy admin who accidentally set it on both OUs instead of just the users)

#Give a group Password reset & re-enable over a given OU
$victim = (Get-ADOrganizationalUnit "ou=User_Accounts,$ADRoot" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity "Helpdesk Tier II").SID
#Allow specific password reset
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("00299570-246d-11d0-a768-00aa006e0529")).guid,"Descendents",([GUID]("bf967aba-0de6-11d0-a285-00aa003049e2")).guid))
#Allow specific WriteProperty on the Enabled attribute
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("a8df73f2-c5ea-11d1-bbcb-0080c76670c0")).guid,"Descendents",([GUID]("bf967aba-0de6-11d0-a285-00aa003049e2")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Give a group Password reset & re-enable over a given OU
$victim = (Get-ADOrganizationalUnit "ou=Server_Admins,$ADRoot" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity "Helpdesk Tier II").SID
#Allow specific password reset
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"ExtendedRight","ALLOW",([GUID]("00299570-246d-11d0-a768-00aa006e0529")).guid,"Descendents",([GUID]("bf967aba-0de6-11d0-a285-00aa003049e2")).guid))
#Allow specific WriteProperty on the Enabled attribute
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("a8df73f2-c5ea-11d1-bbcb-0080c76670c0")).guid,"Descendents",([GUID]("bf967aba-0de6-11d0-a285-00aa003049e2")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Give a user WriteProperty 'Membership' on a given group
$victim = (Get-ADOrganizationalUnit "ou=AD_Admins,$ADRoot" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "Server Admins T2").SID
#Allow specific WriteProperty 'Membership'
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"WriteProperty","ALLOW",([GUID]("bc0ac240-79a9-11d0-9020-00c04fc2d4cf")).guid,"Descendents",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl

#Throw a curveball though, set smartcard login required on all Server Admins
$ServerAdmins = (Get-ADGroupMember "Server Admins").SamAccountName
ForEach ($ServerAdmin in $ServerAdmins)
{
Set-ADUser $ServerAdmin -SmartcardLogonRequired $true
}

#Make AD Admins "self managing", aka give the group GenericAll on itself
#Give a group GenericAll on a given group
$victim = (Get-ADGroup "AD Admins" -Properties *).DistinguishedName
$acl = Get-ACL $victim
$user = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "AD Admins").SID
#Allow specific WriteProperty 'Membership'
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $user,"GenericAll","ALLOW",([GUID]("00000000-0000-0000-0000-000000000000")).guid,"None",([GUID]("00000000-0000-0000-0000-000000000000")).guid))
#Apply above ACL rules
Set-ACL $victim $acl