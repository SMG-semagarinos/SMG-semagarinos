######################################################################################################

$ServerName = "SRVEXCM02-PROD"
#
#region Login Exchange Management Shell localmente
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ServerName/PowerShell/  -Authentication Kerberos #-Credential $UserCredential
Import-PSSession $Session
#Remove-PSSession $Session


#Identifico las 40 bases
$Bases = Get-MailboxDatabase
#Traigo los buzones activos mas de 10109.
$Buzones = Get-Mailbox -ResultSize Unlimited 

##### ACA TITO es lo nuevo #####
#Nuevo para filtrar solo la gente que este en un CSV
$CSV = "SearchEMAIL_Delete.csv"
$CSV = Import-Csv -Path $CSV -Delimiter ";"
$FiltroCSV = @()
$FiltroCSV = foreach ($CSVUsers in $CSV ) {
    $FiltroCSV += $Buzones | Where-Object { $_.UserPrincipalName -eq $CSVUsers.Identity } 
}
#Control de cantidades
$FiltroCSV.count
$CSV.count
$Buzones.count

$Buzones = $FiltroCSV


#Query de busqueda.
#$SearchQuery = 'From:Juha.Pietarinen@savonlinna.fi'
$SearchQuery = 'From:ciide07.educacion@durango.gob.mx'
#Contenedor del resultado
$Resultado = @()

############ Ejecucion masiva ########################################################################################################################
#Recorro base por base para ver los mensajes de los usuarios.
foreach ($base in $Bases ) {
    $Resultado += $Buzones | Where-Object { $_.Database -eq $Base } | Search-Mailbox -SearchQuery $SearchQuery -EstimateResultOnly | Select-Object Identity, ResultItemsCount | Where-Object { $_.ResultItemsCount -gt 0 }
}

$Resultado.count
######################################################################################################