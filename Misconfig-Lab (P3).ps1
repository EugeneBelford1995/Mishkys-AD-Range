#Create a share folder, drop Admin Notes in it, and set permissions
Expand-Archive "C:\Share\AdminStuff\TODO.zip" -DestinationPath "C:\Share\AdminStuff"
Remove-Item "C:\Share\AdminStuff\TODO.zip"
Grant-SmbShareAccess -Name "Share" -AccountName "us\AD Admins" -AccessRight Full -Force

$ACL = Get-Acl -Path "C:\Share\AdminStuff\Admin_Notes.txt"
#Disable inheritance 
$ACL.SetAccessRuleProtection($true,$false)
#Add AD Admins with read rights
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("us\AD Admins","ReadPermissions,TakeOwnership,ChangePermissions","Allow")
#Allow FullControl for Lab\Administrators
$AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("Builtin\Administrators","FullControl","Allow")
#Remove Lab\Users read rights
$AccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("Builtin\Users","Read","Allow")
$AccessRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule("Builtin\Users","ReadPermissions","Allow")

#Apply the above
$ACL.SetAccessRule($AccessRule)
$ACL.SetAccessRule($AccessRule2)
$ACL.RemoveAccessRule($AccessRule3)
$ACL.SetAccessRule($AccessRule4)
$ACL | Set-Acl -Path "C:\Share\AdminStuff\Admin_Notes.txt"