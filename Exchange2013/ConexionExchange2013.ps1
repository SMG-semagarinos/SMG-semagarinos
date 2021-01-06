$ServerName = "SRVEXCM02-PROD"
#
#region Login Exchange Management Shell localmente
#
#Set-ExecutionPolicy RemoteSigned
#$UserCredential = Get-Credential
#$ServerName = "$env:computername"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ServerName/PowerShell/  -Authentication Kerberos #-Credential $UserCredential
Import-PSSession $Session
#Remove-PSSession $Session
#
#
$Server = "SRVEXCM01-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM02-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM03-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM04-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM05-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW01-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW02-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW03-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 



$Server = "SRVEXCM06-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM07-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM08-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM09-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCM10-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW04-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW05-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
$Server = "SRVEXCW06-PROD" ; cd D:\20201116\$Server ; ..\HealthChecker.ps1 -Server $Server 
#
Get-ExchangeServer  | Ft IDENTITY, guid
-Identity "90F12043-3B97-48CE-ABD3-A737980A93AE"
"75281f30-7da0-4792-9186-7ac3348e2755"
cmd
$Info = tasklist | find "ccmsetup.exe"
Set-CASMailbox "cristianbenitez@macro.com.ar" -ActiveSyncDebugLogging:$FALSE
Set-CASMailbox "hacorreo01@macro.com.ar" -ActiveSyncDebugLogging:$true

Get-MailboxDatabase -Status | Select-Object NAME,lastfull*, lastincre* | Out-GridView
$PruebaCalendario = "hacorreo02@macro.com.ar"
Set-CASMailbox $PruebaCalendario -ActiveSyncDebugLogging:$true

Get-MobileDeviceStatistics -Mailbox $PruebaCalendario -GetMailboxLog:$true -NotificationEmailAddresses SebastianMagarinos@macro.com.ar


Get-Mailbox "pabloseeber@macro.com.ar" | Search-mailbox -SearchQuery '[Ticket#10523001]' -TargetMailbox "SebastianMagarinos@macro.com.ar" -TargetFolder "SeeberTicket" -LogLevel Full
Invoke-GPUpdate -Computer SRVAPI9DB-PREP

$Usuarios = Import-Csv -Path "C:\Users\smagarin\Downloads\sendreceive.csv" -Delimiter ";"
$Datos = @()
foreach ($Usuario in $Usuarios){
    $Datos += Get-mailbox $Usuario.mail -ResultSize Unlimited | Get-User | Select-Object UserPrincipalName, Title
}

$Datos.count
$Datos | clip


$Mails = Get-mailbox -ResultSize Unlimited 
$DatosTotal = @()
foreach ($Mail in $Mails){
    $DatosTotal += Get-mailbox $Mail.Alias | Get-User | Select-Object UserPrincipalName, Title
}
$DatosTotal.count
$DatosTotal | clip

$IpsFails = Get-DhcpServerv4Scope -ComputerName SRVDHCP01-PROD | Repair-DhcpServerv4IPRecord -ReportOnly -ComputerName SRVDHCP01-PROD | Select-Object -ExpandProperty IpAddress | Select-Object IPAddressToString
$IpsFails.count
$IpsFails | Clip
Get-mailbox smagarin | fl Select-Object Office
##################
get-mailbox info@avisosmacro.com.ar

Get-DnsServerForwarder -computername dcpiloto

Get-DhcpServerv4Scope -ComputerName SRVDHCP02-PROD | fl 
Import-Module DnsServer
Get-DnsServer -ComputerName DC321

Get-mailbox "*Macro Securities Cumpl*" | fl *auto*
Remove-MailboxPermission -Identity MacrosecuritiesCumplimiento@MACRO.COM.AR -User agustindevoto@macro.com.ar -AccessRights FullAccess
Add-MailboxPermission -Identity MacrosecuritiesCumplimiento@MACRO.COM.AR -User agustindevoto@macro.com.ar -AccessRights FullAccess -AutoMapping $true 


$dateStart = [DateTime]"06/11/2020 04:00" # Fomato MM-DD-YYYY
$dateEnd = [DateTime]"06/11/2020 16:00" # Fomato MM-DD-YYYY
$mailbox = "lorenafernandez@macro.com.ar"
$results = Search-MailboxAuditLog -Identity $mailbox -ShowDetails -StartDate $dateStart -EndDate $dateEnd -Resultsize 25000
$results.count


#endregion


$changos = Get-Mailbox -ResultSize unlimited

$changos | 
	Select-Object -Property SamAccountName, DisplayName, PrimarySmtpAddress, Database, IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota, UseDatabaseQuotaDefaults |
	Sort-Object -Property SamAccountName |
	Export-Csv -Path "c:\changos.csv" -NoTypeInformation -UseCulture


Set-MailboxAutoReplyConfiguration -Identity maximilianoerbin@macro.com.ar -AutoReplyState Enabled -InternalMessage "Actualmente me encuentro fuera de la oficina. Me reintegro el 03/2020, por urgencias comunicarse a tec_telefonia"


Get-Mailbox smagarin | fl
Get-Mailbox smagarin | fl *limit*



If($Mailbox.UseDatabaseQuotaDefaults -eq $true ){
    #Nuevo Item
    If($bd.ProhibitSendReceiveQuota -ge $Tier15){
    #Write-Host $DB.IssueWarningQuota -ForegroundColor Green 
    #Set-Mailbox $Mailbox -CustomAttribute13 "Tier50"
    $Cant50GB += 1
    $Users50GB += $RegistroBuzon
    } 

    elseif($bd.ProhibitSendReceiveQuota -ge $Tier5 -AND $bd.ProhibitSendReceiveQuota -lt $Tier15){
    #Write-Host $DB.IssueWarningQuota -ForegroundColor Green 
    #Set-Mailbox $Mailbox -CustomAttribute13 "Tier15"
    $Cant15GB += 1
    $Users15GB += $RegistroBuzon
    }

    elseif($bd.ProhibitSendReceiveQuota -ge $Tier1 -AND $bd.ProhibitSendReceiveQuota -lt $Tier5){
    #Write-Host $DB.IssueWarningQuota -ForegroundColor Green 
    #Set-Mailbox $Mailbox -CustomAttribute13 "Tier5"
    $Cant5GB += 1
    $Users5GB += $RegistroBuzon
    }

    else{
    #Write-Host $DB.IssueWarningQuota -ForegroundColor Green
    #Set-Mailbox $Mailbox -CustomAttribute13 ""
    $Cant1GB += 1
    $Users1GB += $RegistroBuzon
    }
}
Else { 
}




$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -AllowRedirection
