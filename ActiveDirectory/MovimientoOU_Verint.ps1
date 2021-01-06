#Movimiento de OU de EQuipos de Verint.


Import-Module ActiveDirectory
$Servidores = @(
    "SRVVEDCE01-PROD"
    "SRVVEREC01-PROD"
    "SRVVEREC02-PROD"
    "SRVVEREC03-PROD"
    "SRVVEREC04-PROD"
    "SRVVEREC05-PROD"
    "SRVSPEERAS-PROD"
    "SRVSPEETRS-PROD"
    "SRVVEWFM-PROD"
    "SRVVEDB01-PROD"
)
$OUProcesoDeInstalacion = "OU=En proceso de Instalacion,OU=Servidores,DC=MACRO,DC=COM,DC=AR"
$OUProduccion = "OU=Produccion,OU=Servidores,DC=MACRO,DC=COM,DC=AR"
####

$OUDestino = $OUProcesoDeInstalacion
#movimiento hacia EN PROCESO DE INSTALACION
foreach ($Servidor in $Servidores) {
    $InfoADComputer = Get-ADComputer $Servidor
    $InfoADComputer | Move-ADObject -TargetPath $OUDestino  
        Write-Host $InfoADComputer.DNSHostName -ForegroundColor Red
        Write-Host "Se mueve el equipo hacia " -ForegroundColor Green -NoNewline
        Write-Host $OUDestino -ForegroundColor Red -NoNewline
        Write-Host " desde " -ForegroundColor Green -NoNewline
        Write-Host $InfoADComputer.DistinguishedName -ForegroundColor Red
    Invoke-GpUpdate -Computer $Servidor -Force 
        Write-Host "Enviada la orden de GPUPDATE remoto al equipo: " -ForegroundColor Green -NoNewline
        Write-Host $Servidor -ForegroundColor Red
}


$OUDestino = $OUProduccion
#movimiento a PRODUCCION.
foreach ($Servidor in $Servidores) {
    $InfoADComputer = Get-ADComputer $Servidor
    $InfoADComputer | Move-ADObject -TargetPath $OUDestino 
        Write-Host $InfoADComputer.DNSHostName -ForegroundColor Red
        Write-Host "Se mueve el equipo hacia " -ForegroundColor Green -NoNewline
        Write-Host $OUDestino -ForegroundColor Red -NoNewline
        Write-Host " desde " -ForegroundColor Green -NoNewline
        Write-Host $InfoADComputer.DistinguishedName -ForegroundColor Red
    Invoke-GpUpdate -Computer $Servidor -Force 
        Write-Host "Enviada la orden de GPUPDATE remoto al equipo: " -ForegroundColor Green -NoNewline
        Write-Host $Servidor -ForegroundColor Red
}

