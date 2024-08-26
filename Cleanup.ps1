#Cleanup/delete a VM
#Remove-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0

Function Cleanup-VM
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $VMName,
         [Parameter(Mandatory=$false, Position=1)]
         [string] $IP
    )

Write-Host "This will delete the VM, it's HD, and it's AD account. Only run this if you are sure that you're done with the VM."
#Alt
Stop-VM -Name $VMName -Force
Get-VMHardDiskDrive -VMName $VMName | Remove-VMHardDiskDrive
Remove-VM -Name $VMName -Confirm
Remove-Item "C:\Hyper-V_VMs\$VMName" -Recurse
#Remove-ADComputer "$VMName" -Confirm

#https://pscustomobject.github.io/powershell/howto/PowerShell-ISE-Clear-Variables/
#Remove-Variable * -ErrorAction SilentlyContinue
#$error.Clear()
#Remove-Module *
}