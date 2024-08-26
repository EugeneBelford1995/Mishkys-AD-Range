Write-Host "Generate-Traffic simulates a user on US-Client fat fingering a share drive every few minutes."
Function Generate-Traffic
{
#Run this on ThePunisher to simulate a user fat fingering a share drive
#On Kali: sudo responder -I eth0 -dwv

[string]$userName = 'us\Bill.Lumbergh'
[string]$userPassword = 'Password12'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$BillLumberghCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

$X = 0
Do
{
Invoke-Command -VMName "US-Client" {Get-Content "\\NoExist\C$"} -Credential $BillLumberghCredObject
Start-Sleep -Seconds 120
$X = $X + 1
}
While($X -le 10)
} #Close the function