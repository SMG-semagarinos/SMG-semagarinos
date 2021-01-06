$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername . | Where-Object {$_.IPEnabled -eq $True -and $_.DHCPEnabled -eq $True}
 
 Foreach($NIC in $NICs) {
 $Ip = "172.31.154.117"
 $Gateway = "172.31.152.1"
 $Subnet = "255.255.248.0"
 $DNS = "172.31.154.98"
 $NIC.EnableStatic($Ip, $Subnet)
 $NIC.SetGateways($Gateway)
 $NIC.SetDNSServerSearchOrder($DNS)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
 }
#IPConfig /all

$PathLogServidores = "C:\z-ServidoresTools\AccionesGenerales.log"
Write-Host "Se realizo configuracion de IP asignada por DHCP - $($NIC.IPAddress[0])" >> $PathLogServidores
