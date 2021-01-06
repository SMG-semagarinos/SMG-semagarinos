# Lectura de Logs
$Servidores = @("SRVEXCM01-PROD","SRVEXCM02-PROD","SRVEXCM03-PROD","SRVEXCM04-PROD","SRVEXCM05-PROD","SRVEXCM06-PROD","SRVEXCM07-PROD","SRVEXCM08-PROD","SRVEXCM09-PROD","SRVEXCM10-PROD","SRVEXCW01-PROD","SRVEXCW02-PROD","SRVEXCW03-PROD","SRVEXCW04-PROD","SRVEXCW05-PROD")
$FechaNecesaria = Get-Date ("27/12/2019")
$LogUnable = @()
$EventosBuscados = @("550 5.7.1")
###########"550 5.7.1 Unable to relay,"
$PathLogs = @("D$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive")
$PathLogs += @("D$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive")
$IDsConn = @("08D78A52C2C47F7E","08D78A52C2C48148")
$StringOrID = "ID"

#Recorro Servidores
foreach ($Servidor in $Servidores) {
    #Recorro Pathlogs y Archivos.
    foreach ($PathLog in $PathLogs){
    $Archivos = Get-ChildItem  "\\$Servidor\$PathLog" | Where-Object { $_.LastWriteTime -gt $($FechaNecesaria) -AND $_.LastWriteTime -lt $($FechaNecesaria).AddDays(1) }
        #Recorro archivo de log.
        foreach ($ArchivoLog in $Archivos){
            if($StringOrID -eq "ID"){
                #Busqueda de ID's
                foreach ($ID in $IDsConn){
                    $LogIDConn += Get-Content $ArchivoLog.FullName | Select-String -Pattern $ID
                }
            }elseif ($StringOrID -eq "String") {
                foreach ($EventoBuscado in $EventosBuscados){
                    $LogString += Get-Content $ArchivoLog.FullName | Select-String -Pattern $EventoBuscado
                }
            }else{
                Write-Host "Nada para buscar" -ForegroundColor Red
            }
            
        }
    }
}
#Entablar.
$Encabezado = "Fecha","Conector","IDConexion","Campo1","IpPuertoServidor","IpPuertoRemoto","Direccion","Evento","Vacio"
if($StringOrID -eq "ID"){
    #Busqueda de ID's
    $LogTableID = $LogIDConn | ConvertFrom-Csv -Header $Encabezado -Delimiter ","
    Write-Host "Se encontraron $(($LogIDConn | Sort-Object IDConexion -Unique).count) eventos de esos IDs" -ForegroundColor Green
    $LogTableID | ft
}elseif ($StringOrID -eq "String") {
    $LogTable = $LogString | ConvertFrom-Csv -Header $Encabezado -Delimiter "," | Sort-Object IDConexion -Unique
    Write-Host "Se encontraron $($LogString.Count) y unicos $($LogTable.Count) eventos *$EventosBuscado*" -ForegroundColor Red
}else{
    Write-Host "REVISAR STRING" -ForegroundColor Red
}


