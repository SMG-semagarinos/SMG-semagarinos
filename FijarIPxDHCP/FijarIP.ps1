$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername . | Where-Object {$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true}
 Foreach($NIC in $NICs) {
 $ip = ($NIC.IPAddress[0])
 $gateway = $NIC.DefaultIPGateway
 $subnet = $NIC.IPSubnet[0]
 $dns = $NIC.DNSServerSearchOrder
 $NIC.EnableStatic($ip, $subnet)
 $NIC.SetGateways($gateway)
 $NIC.SetDNSServerSearchOrder($dns)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
 }
#IPConfig /all

$PathLogServidores = "C:\z-ServidoresTools\AccionesGenerales.log"
Write-Host "Se realizo configuracion de IP asignada por DHCP - $($NIC.IPAddress[0])" >> $PathLogServidores
