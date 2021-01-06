# Lectura de Logs
$Servidores = @("SRVEXCM01-PROD","SRVEXCM02-PROD","SRVEXCM03-PROD","SRVEXCM04-PROD","SRVEXCM05-PROD","SRVEXCM06-PROD","SRVEXCM07-PROD","SRVEXCM08-PROD","SRVEXCM09-PROD","SRVEXCM10-PROD","SRVEXCW01-PROD","SRVEXCW02-PROD","SRVEXCW03-PROD","SRVEXCW04-PROD","SRVEXCW05-PROD")
#$Servidores = @("SRVEXCM04-PROD")
$FechaNecesaria = Get-Date ("27/12/2019")
$LogUnable = @()
###########
foreach ($Servidor in $Servidores)
{
$Archivos = Get-ChildItem  "\\$Servidor\D$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive" | Where-Object { $_.LastWriteTime -gt $($FechaNecesaria) -AND $_.LastWriteTime -lt $($FechaNecesaria).AddDays(1) }

    foreach ($ArchivoLog in $Archivos){
#        $LogUnable += Get-Content $ArchivoLog.FullName | Select-String -Pattern "550 5.7.1 Unable to relay,"
        $LogUnable += Get-Content $ArchivoLog.FullName | Select-String -Pattern "error"
        
    }
}

$LogUnable.Count
#Convertir a CSV.
$Encabezado = "Fecha","Conector","IDConexion","Campo1","IpPuertoServidor","IpPuertoRemoto","Direccion","Evento","Vacio"
$LogTableUnable = $LogUnable | ConvertFrom-Csv -Header $Encabezado -Delimiter ","

$LogTableUnable.count
$LogTableUnable | ft
#$Filtrado = $LogTableUnable | Select-Object IDConexion, Conector, Ip*  | Where-Object { $_.Conector -like "*AppInternal*"} | Sort-Object IDConexion -Unique
$Filtrado = $LogTableUnable | Select-Object IDConexion, Conector, Ip*  | Sort-Object IDConexion -Unique
#$Filtrado = $LogTableUnable | Where-Object { $_.Conector -like "*AppInternal*"} | Sort-Object IDConexion -Unique
$Filtrado = $LogTableUnable | Sort-Object IDConexion -Unique
$Filtrado.count
$Filtrado = $LogTableUnable | Sort-Object IDConexion -Unique
$Filtrado | Export-Csv -Path \\000tec11\Transito\Errores.CSV -NoTypeInformation -Force
Invoke-Item \\000tec11\Transito\Errores.CSV 





###########################
$Servidores = @("SRVEXCM01-PROD","SRVEXCM02-PROD","SRVEXCM03-PROD","SRVEXCM04-PROD","SRVEXCM05-PROD","SRVEXCM06-PROD","SRVEXCM07-PROD","SRVEXCM08-PROD","SRVEXCM09-PROD","SRVEXCM10-PROD","SRVEXCW01-PROD","SRVEXCW02-PROD","SRVEXCW03-PROD","SRVEXCW04-PROD","SRVEXCW05-PROD")
#$Servidores = @("SRVEXCM04-PROD")
$FechaNecesaria = Get-Date ("17/12/2019")
$LogUnable = @()

###########
foreach ($Servidor in $Servidores)
{


$Archivos = Get-ChildItem  "\\$Servidor\d$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive" | Where-Object { $_.LastWriteTime -gt $($FechaNecesaria) -AND $_.LastWriteTime -lt $($FechaNecesaria).AddDays(1) }

    foreach ($ArchivoLog in $Archivos){
#        $LogUnable += Get-Content $ArchivoLog.FullName | Select-String -Pattern "550 5.7.1 Unable to relay,"
        $LogUnable += Get-Content $ArchivoLog.FullName | Select-String -Pattern "421 4.4.2"
        
    }
}
$LogUnable.Count
#Convertir a CSV.
$Encabezado = "Fecha","Conector","IDConexion","Campo1","IpPuertoServidor","IpPuertoRemoto","Direccion","Evento","Vacio"
$LogTableUnable = $LogUnable | ConvertFrom-Csv -Header $Encabezado -Delimiter ","

$LogTableUnable.count
$LogTableUnable[1]
#$Filtrado = $LogTableUnable | Select-Object IDConexion, Conector, Ip*  | Where-Object { $_.Conector -like "*AppInternal*"} | Sort-Object IDConexion -Unique
$Filtrado = $LogTableUnable | Select-Object IDConexion, Conector, Ip*  | Sort-Object IDConexion -Unique
#$Filtrado = $LogTableUnable | Where-Object { $_.Conector -like "*AppInternal*"} | Sort-Object IDConexion -Unique
$Filtrado = $LogTableUnable | Sort-Object IDConexion -Unique
$Filtrado.count
$Filtrado = $LogTableUnable | Sort-Object IDConexion -Unique
$Filtrado | Export-Csv -Path \\000tec11\Transito\Errores.CSV -NoTypeInformation -Force
Invoke-Item \\000tec11\Transito\Errores.CSV 
#----------------------------------------------------------------------------------------------------------
$LogUnableIDCon = @()
foreach ($Servidor in $Servidores)
{

$Archivos = Get-ChildItem  "\\$Servidor\d$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive" | Where-Object { $_.LastWriteTime -gt $($FechaNecesaria)}

    foreach ($ArchivoLog in $Archivos){
        #foreach ($IDCon in $LogTableUnable){
            $LogUnableIDCon += Get-Content $ArchivoLog.FullName | Select-String -Pattern "08D71D4C40B166AD"
        #}
        
    }
}
$LogUnableIDCon 


$LogTableUnable[1]
#Convertir a CSV.
$Encabezado = "Fecha","Conector","IDConexion","IDConversacion","IpPuertoServidor","IpPuertoRemoto","Direccion","Evento","Vacio"
$LogTableIDConUnable = $LogUnable | ConvertFrom-Csv -Header $Encabezado -Delimiter ","
#
$LogTableIDConUnable | Select-Object IDConexion, Conector, Ip*  | Sort-Object IDConexion -Unique 

