######################################################################################################

$ServerName = "SRVEXCM02-PROD"
#
#region Login Exchange Management Shell localmente
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri [http://$ServerName/PowerShell/]http://$ServerName/PowerShell/  -Authentication Kerberos #-Credential $UserCredential
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
$Buzones = foreach ($CSVUsers in $CSV ) {} $Buzones | Where-Object { $_.Identity -eq $CSVUsers.name } }


#Contenedor del resultado
$Resultado = @()

############ Ejecucion masiva ########################################################################################################################
#Recorro base por base para ver los mensajes de los usuarios.
foreach ($base in $Bases ) {
    $Resultado += $Buzones | Where-Object { $_.Database -eq $Base } | Search-Mailbox -SearchQuery 'From:Juha.Pietarinen@savonlinna.fi' -EstimateResultOnly | Select-Object Identity, ResultItemsCount | Where-Object { $_.ResultItemsCount -gt 0 }
}

$Resultado.count
######################################################################################################