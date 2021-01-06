$start = [DateTime]"04/28/2020 00:01"
$end = [DateTime]"04/28/2020 18:00"
$sender = "bbrother@macro.com.ar"
#$recipient = "mariaeugeniamolina@macro.com.ar"
#$results = Get-TransportService | Get-MessageTrackingLog -Recipient $recipient -Start $start -End $end
$results = Get-TransportService | Get-MessageTrackingLog -Sender $sender -Start $start -End $end -MessageSubject "SRVH24-PROD-Link.map32_err red" -Server $_.Name

Foreach ($Server in (Get-TransportService)){

	$results = Get-MessageTrackingLog -Sender $sender -Start $start -End $end -MessageSubject "SRVH24-PROD-Link.map32_err red" -Server SRVEXCM05-PROD -EventId FAIL | fl

}

Get-MessageTrackingLog -Sender $sender -Start $start -End $end -MessageSubject "SRVH24-PROD-Link.map32_err red" -Server SRVEXCM07-PROD -EventId FAIL | fl

Get-DistributionGroup analistas_atm@grupomacro.com.ar | fl
Set-DistributionGroup analistas_banelco@macro.com.ar -RequireSenderAuthenticationEnabled $False

$results |
		Select-Object -Property Timestamp, ServerHostname, ClientHostname, Source, EventId, MessageId, Sender, `
					  @{
			l = 'Recipients'
			e = {
				$_.Recipients -join ' '
			}
		}, MessageSubject,
					  @{
			l = 'RecipientStatus';
			e = { $_.RecipientStatus }
		} |
	`
		Sort-Object -Property Timestamp |
		Export-Csv -Path "C:\z-Transito\bb.csv" -NoTypeInformation -UseCulture



# Busqueda por MessageID
# $results = Get-TransportService | Get-MessageTrackingLog -MessageId qeysmgqwmsyekqeysmgauoicwqkesykw