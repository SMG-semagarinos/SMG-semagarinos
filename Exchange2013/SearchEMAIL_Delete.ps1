#region # Conexion hacia Exchange Server ####################################################
$ServerName = "SRVEXCM02-PROD"
#
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ServerName/PowerShell/  -Authentication Kerberos #-Credential $UserCredential
Import-PSSession $Session
#Remove-PSSession $Session
#endregion 
#############################################################################################

#region # Preparacion de CSV ################################################################
#Nuevo para filtrar solo la gente que este en un CSV
$CSV = "SearchEMAIL_Delete.csv"
$CSV = Import-Csv -Path $CSV -Delimiter ";"
#endregion
#############################################################################################

#region # Query de busqueda #################################################################
#$SearchQuery = 'From:Juha.Pietarinen@savonlinna.fi'
$SearchQuery = 'From:ciide07.educacion@durango.gob.mx'
#endregion
#############################################################################################

#region #### Comienza la busqueda MASIVA ####################################################
#Recorro Usuarios desde un CSV NO MAS DE 500 usuarios.
$ResultadoEstimado = @()
foreach ($CSVUsers in $CSV ) {
    $ResultadoEstimado += Search-Mailbox -Identity $CSVUsers.Identity -SearchQuery $SearchQuery -EstimateResultOnly | Select-Object Identity, ResultItemsCount | Where-Object { $_.ResultItemsCount -gt 0 }
}
##Informe del resultado 
Write-Host "####################" -ForegroundColor Yellow
Write-Host "El Resultado de la busqueda de dicha query " -NoNewline -ForegroundColor Green
Write-Host $SearchQuery -NoNewline -ForegroundColor Red
Write-Host " dio que se encuentran " -NoNewline -ForegroundColor Green
Write-Host  $ResultadoEstimado.count -NoNewline -ForegroundColor Yellow
Write-Host " Mails " -ForegroundColor Red
Write-Host "####################" -ForegroundColor Yellow
##Informe del resultado 

#Preguntamos si borramos
$Borramos = @()
$Borramos = Read-Host "Quieres borrar? (Y or N)"
If ( $Borramos -eq "Y" -or $Borramos -eq "y") {
    Write-Host "####################" -ForegroundColor Yellow
    Write-Host "Comenzamos el borrado de $SearchQuery " -ForegroundColor Yellow
    $ResultadoBorrado = @()
    #
    foreach ($CSVUsers in $CSV ) {
        $ResultadoBorrado += Search-Mailbox -Identity $CSVUsers.Identity -SearchQuery $SearchQuery -DeleteContent -Force
    }
    Write-Host "####################" -ForegroundColor Yellow
    $Borramos = @()
}Else {
    Write-Host "########## " -ForegroundColor Green
    Write-Host "No hicimos nada papa!! tranquilo" -ForegroundColor Green
    $Borramos = @()
}


$ResultadoBorrado.count
###############################################################################################################################
##################################
## Otra opcion:
# Recorro base por base para ver los mensajes de los usuarios.
# Identifico las 40 bases
$Bases = Get-MailboxDatabase
#Traigo los buzones activos mas de 10000.
$Buzones = Get-Mailbox -ResultSize Unlimited 
# Comienzo a buscar base por base.
$ResultadoEstimadoDB = @()

foreach ($base in $Bases ) {
    $ResultadoEstimadoDB += $Buzones | Where-Object { $_.Database -eq $Base } | Search-Mailbox -SearchQuery $SearchQuery -EstimateResultOnly | Select-Object Identity, ResultItemsCount | Where-Object { $_.ResultItemsCount -gt 0 }
}

##Informe del resultado 
Write-Host "####################" -ForegroundColor Yellow
Write-Host "El Resultado de la busqueda de dicha query en cada base de datos" -NoNewline -ForegroundColor Green
Write-Host $SearchQuery -NoNewline -ForegroundColor Red
Write-Host " dio que se encuentran " -NoNewline -ForegroundColor Green
Write-Host  $ResultadoEstimadoDB.count -NoNewline -ForegroundColor Yellow
Write-Host " Mails " -ForegroundColor Red
Write-Host "####################" -ForegroundColor Yellow
##Informe del resultado 

#Preguntamos si borramos
$Borramos = @()
$Borramos = Read-Host "Quieres borrar? (Y or N)"
If ( $Borramos -eq "Y" -or $Borramos -eq "y") {
    Write-Host "####################" -ForegroundColor Yellow
    Write-Host "Comenzamos el borrado de $SearchQuery " -ForegroundColor Yellow
    $ResultadoBorradoDB = @()
    #
    foreach ($CSVUsers in $CSV ) {
        $ResultadoBorradoDB += $Buzones | Where-Object { $_.Database -eq $Base } | Search-Mailbox -Identity $CSVUsers.Identity -SearchQuery $SearchQuery -DeleteContent -Force
    }
    Write-Host "####################" -ForegroundColor Yellow
    $Borramos = @()
}Else {
    Write-Host "########## " -ForegroundColor Green
    Write-Host "No hicimos nada papa!! tranquilo" -ForegroundColor Green
    $Borramos = @()
}
