Function Create-SW
{
#Show how to enable Hyper-V & create a VMSwitch
New-VMSwitch -Name "Testing" -NetAdapterName "Ethernet" ; Set-VMSwitch -Name Testing -AllowManagementOS $true
}

Function Create-VM
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $VMName,
         [Parameter(Mandatory=$false, Position=1)]
         [string] $IP
    )

#Creates the VM from a provided ISO & answer file, names it provided VMName
Set-Location "C:\VM_Stuff_Share\Lab"
$isoFilePath = "..\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"
$answerFilePath = ".\2022_autounattend.xml"

New-Item -ItemType Directory -Path C:\Hyper-V_VMs\$VMName

$convertParams = @{
    SourcePath        = $isoFilePath
    SizeBytes         = 100GB
    Edition           = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
    VHDFormat         = 'VHDX'
    VHDPath           = "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
    DiskLayout        = 'UEFI'
    UnattendPath      = $answerFilePath
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
. '..\Convert-WindowsImage (from PS Gallery)\Convert-WindowsImage.ps1'

Convert-WindowsImage @convertParams

New-VM -Name $VMName -Path "C:\Hyper-V_VMs\$VMName" -MemoryStartupBytes 6GB -Generation 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 6GB -StartupBytes 6GB -MaximumBytes 8GB
Connect-VMNetworkAdapter -VMName $VMName -Name "Network Adapter" -SwitchName "Testing"
$vm = Get-Vm -Name $VMName
$vm | Add-VMHardDiskDrive -Path "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
$bootOrder = ($vm | Get-VMFirmware).Bootorder
#$bootOrder = ($vm | Get-VMBios).StartupOrder
if ($bootOrder[0].BootType -ne 'Drive') {
    $vm | Set-VMFirmware -FirstBootDevice $vm.HardDrives[0]
    #Set-VMBios $vm -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
}
Start-VM -Name $VMName
}#Close the Create-VM function

#Create-SW
#Write-Host "Creating VMSwitch, please standby ..."
#Start-Sleep -Seconds 30

Create-VM -VMName "Lab-DC"      #Create the parent domain's DC
Create-VM -VMName "US-DC"       #Create the child domain's DC
Create-VM -VMName "US-Client"   #Create the child domain's client
Create-VM -VMName "US-ClientII" #Create the child domain's other client
Write-Host "Please wait, the VMs are booting up."
Start-Sleep -Seconds 180

#Create the parent domain
Function Create-ParentDomain
{
#VM's initial local admin:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin after re-naming the computer:
[string]$userName = "Lab-DC\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$LabDCLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's Domain Admin:
[string]$userName = "lab\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ParentDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Lab-DC" -FilePath '.\VMConfig (ParentDC P1).ps1' -Credential $InitialCredObject   #Configs IPv4, disables IPv6, renames the VM
Start-Sleep -Seconds 120
Invoke-Command -VMName "Lab-DC" -FilePath '.\VMConfig (ParentDC P2).ps1' -Credential $LabDCLocalCredObject   #Makes the VM a DC in a new forest; lab.local
Start-Sleep -Seconds 300 
Invoke-Command -VMName "Lab-DC" -FilePath '.\VMConfig (ParentDC P3).ps1' -Credential $ParentDomainAdminCredObject   #Creates a Backup Enterprise Administrator account name Break.Glass

#Last step; set the Administrator password

#us.lab.local Ent Admin:
[string]$userName = "lab\Break.Glass"
[string]$userPassword = 'SuperSecureDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ParentDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Lab-DC" {Set-ADAccountPassword -Identity "Administrator" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText 'SuperSecureDomainPassword1234!@#$' -Force)} -Credential $ParentDomainAdminCredObject

} #Close the Create-ParentDomain function


# --- Create the child domain ---
Function Create-ChildDomain
{

#VM's initial local admin:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin after re-naming the computer:
[string]$userName = "US-DC\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$USDCLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's Domain Admin:
[string]$userName = "us\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ChildDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Run the files to config US-DC & US-Client
Invoke-Command -VMName "US-DC" -FilePath '.\VMConfig (ChildDC P1).ps1' -Credential $InitialCredObject   #Configs IPv4, disables IPv6, renames the VM
Start-Sleep -Seconds 120
Invoke-Command -VMName "US-DC" -FilePath '.\VMConfig (ChildDC P2).ps1' -Credential $USDCLocalCredObject   #Makes the VM a DC for the child domain
Start-Sleep -Seconds 300
#'Guest Service Interface' must be enabled for Copy-VMFile to work
Enable-VMIntegrationService "Guest Service Interface" -VMName "US-DC"
Copy-VMFile "US-DC" -SourcePath ".\Users.csv" -DestinationPath "C:\Users.csv" -CreateFullPath -FileSource Host -Credential $ChildDomainAdminCredObject
Start-Sleep -Seconds 30 
Invoke-Command -VMName "US-DC" -FilePath '.\VMConfig (ChildDC P3).ps1' -Credential $ChildDomainAdminCredObject   #Creates the OUs, users, & groups in us.lab.local

#Last step; set the Administrator password

#us.lab.local backup Domain Admin
[string]$userName = "us\Break.Glass"
[string]$userPassword = 'SuperSecureDomainPassword12!@'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ChildDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "US-DC" {Set-ADAccountPassword -Identity "Administrator" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText 'SuperSecureDomainPassword12!@' -Force)} -Credential $ChildDomainAdminCredObject

# --- Setup US-Client ---

#VM's local admin after re-naming the computer:
[string]$userName = "US-Client\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$USClientLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Jen.Barber domain cred:
[string]$userName = "us\jen.barber"
[string]$userPassword = 'Password00!!'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$JenCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "US-Client" -FilePath '.\VMConfig (ChildClient P1).ps1' -Credential $InitialCredObject   #Configs IPv4, disables IPv6, renames the VM
Start-Sleep -Seconds 120
Invoke-Command -VMName "US-Client" -FilePath '.\VMConfig (ChildClient P2).ps1' -Credential $USClientLocalCredObject   #Joins us.lab.local
Start-Sleep -Seconds 120
Invoke-Command -VMName "US-Client" -FilePath '.\VMConfig (ChildClient P3).ps1' -Credential $ChildDomainAdminCredObject #Cache Frisky.McRisky's creds in credman, reset local admin's pwd, add groups to local admin

# --- Setup US-ClientII ---

#VM's local admin after re-naming the computer:
[string]$userName = "US-ClientII\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$USClientIILocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "US-ClientII" -FilePath '.\VMConfig (ChildClientII P1).ps1' -Credential $InitialCredObject #Configs IPv4, disables IPv6, renames the VM
Start-Sleep -Seconds 120
Invoke-Command -VMName "US-ClientII" -FilePath '.\VMConfig (ChildClient P2).ps1' -Credential $USClientIILocalCredObject   #Joins us.lab.local
Start-Sleep -Seconds 120
Invoke-Command -VMName "US-ClientII" -FilePath '.\VMConfig (ChildClientII P3).ps1' -Credential $ChildDomainAdminCredObject #set local admin's pwd the same as us\Stephen.Falken, add groups to local admin

} #Close Create-ChildDomain function

Create-ParentDomain
Start-Sleep -Seconds 120
Create-ChildDomain

#Misconfig the Child Domain
Invoke-Command -VMName "US-DC" -FilePath '.\Misconfig-Lab (P1).ps1' -Credential $ChildDomainAdminCredObject #Create the share drive & set Manage.AD = Read, Domain Admins = FullControl

#Drop a zip file full of PS1s into the folder & then unzip them
Copy-VMFile "US-DC" -SourcePath ".\Notes.txt" -DestinationPath "C:\Share\Notes.txt" -CreateFullPath -FileSource Host
Copy-VMFile "US-DC" -SourcePath .\ShareDriveFiles.zip -DestinationPath "C:\Share\ManageAD\ShareDriveFiles.zip" -CreateFullPath -FileSource Host
Copy-VMFile "US-DC" -SourcePath .\TODO.zip -DestinationPath "C:\Share\AdminStuff\TODO.zip" -CreateFullPath -FileSource Host
Start-Sleep -Seconds 30
Invoke-Command -VMName "US-DC" {Expand-Archive -LiteralPath "C:\Share\ManageAD\ShareDriveFiles.zip" -DestinationPath "C:\Share\ManageAD"} -Credential $ChildDomainAdminCredObject #Unzip the PS1s
Invoke-Command -VMName "US-DC" {Remove-Item "C:\Share\ManageAD\ShareDriveFiles.zip" -Force} -Credential $ChildDomainAdminCredObject #Remove the Zip file

Invoke-Command -VMName "US-DC" '.\Misconfig-Lab (P2).ps1' -Credential $ChildDomainAdminCredObject #Setup the delegations of rights in AD and throw a curveball
Invoke-Command -VMName "US-DC" '.\Misconfig-Lab (P3).ps1' -Credential $ChildDomainAdminCredObject #Set permissions on the Notes