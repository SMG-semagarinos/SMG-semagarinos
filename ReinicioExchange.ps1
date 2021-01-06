#
Restart-Computer -ComputerName SRVEXCM01-PROD -Force
Restart-Computer -ComputerName SRVEXCM06-PROD -Force
#
Restart-Computer -ComputerName SRVEXCM02-PROD -Force
Restart-Computer -ComputerName SRVEXCM07-PROD -Force
#
$ServerDAG1 = "SRVEXCW03-PROD"
$ServerDAG2 = "SRVEXCW06-PROD"
Set-MailboxServer $ServerDAG1 -DatabaseCopyActivationDisabledAndMoveNow $true
Set-MailboxServer $ServerDAG2 -DatabaseCopyActivationDisabledAndMoveNow $true
Get-MailboxDatabaseCopyStatus -Server $ServerDAG1 
Get-MailboxDatabaseCopyStatus -Server $ServerDAG2 

Restart-Computer -ComputerName $ServerDAG1 -Force
Restart-Computer -ComputerName $ServerDAG2 -Force   

Set-MailboxServer $ServerDAG1 -DatabaseCopyActivationDisabledAndMoveNow $false
Set-MailboxServer $ServerDAG2 -DatabaseCopyActivationDisabledAndMoveNow $false
#
Get-MailboxServer * | ft Identity, DatabaseCopyActivationDisabledAndMoveNow