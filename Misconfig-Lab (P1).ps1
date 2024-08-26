#setup Manage.AD account for Kerberoasting
$Password = (ConvertTo-SecureString -AsPlainText "Password1234" -Force)
New-ADUser -Name "Manage AD" -Description "Manage AD" -SamAccountName "Manage.AD" -UserPrincipalName "Manage.Ad@us.lab.local" -Path "ou=User_Accounts,dc=us,dc=lab,dc=local" -AccountPassword $Password -PasswordNeverExpires $true -Enabled $true
Set-ADUser -Identity "Manage.AD" -ServicePrincipalNames @{Add="Manage.AD/us.lab.local"}

#Create a share drive, put Reset-Password.ps1 in it, and give Manage.AD read access. Give Domain Admins FullControl, revoke all others rights.

New-Item "C:\Share" -ItemType Directory
New-Item "C:\Share\ManageAD" -ItemType Directory
New-SMBShare -Name "Share" -Path "C:\Share"

Set-Location C:
$ACL = Get-Acl -Path "C:\Share\ManageAD"
#Disable inheritance 
$ACL.SetAccessRuleProtection($true,$false)
#Add Kerberoast.Me with read rights
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("us\Manage.AD","Read","ContainerInherit,ObjectInherit","None","Allow")
#Allow FullControl for us\Administrators
$AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("builtin\Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
#Remove us\Users read rights
$AccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("builtin\Users","Read","Allow")

#Apply the above
$ACL.SetAccessRule($AccessRule)
$ACL.SetAccessRule($AccessRule2)
$ACL.RemoveAccessRule($AccessRule3)
$ACL | Set-Acl -Path "C:\Share\ManageAD"
#Confirm
#(Get-Acl -Path "C:\Lab Share\Sensitive").Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize