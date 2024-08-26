#Get the VM's default GW: (Get-NetIPConfiguration -InterfaceAlias "vEthernet (Testing)").IPv4DefaultGateway.NextHop
#Get the VM's current IP: (Get-NetIPConfiguration -InterfaceAlias "vEthernet (Testing)").IPv4Address.IPAddress

$GW = (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).InterfaceAlias).IPv4DefaultGateway.NextHop
#Alt method: ($GW -split("\."))[0]
$FirstOctet =  $GW.Split("\.")[0]
$SecondOctet = $GW.Split("\.")[1]
$ThirdOctet = $GW.Split("\.")[2]

$NetworkPortion = "$FirstOctet.$SecondOctet.$ThirdOctet"
#Test this works in our lab: ping "$NetworkPortion.101"

$Gateway = $GW
$NIC = (Get-NetAdapter).InterfaceAlias
$IP = "$NetworkPortion.141"

#Set IPv4 address, gateway, & DNS servers
New-NetIPAddress -InterfaceAlias $NIC -AddressFamily IPv4 -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses ("$NetworkPortion.140", "$NetworkPortion.141", "1.1.1.1", "8.8.8.8")
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

#Disable IPv6 
Disable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Rename-Computer -NewName "US-DC" -PassThru -Restart -Force