Install-Module -Name Microsoft.Online.SharePoint.PowerShell

$adminUPN="sebastianmagarinos@MACRO.COM.AR"
$orgName="macro1"
Connect-SPOService -Url https://$orgName-admin.sharepoint.com 

Get-SPOSite -Template REDIRECTSITE#0
Get-SPOSite

Get-SPODeletedSite 
Remove-SPODeletedSite https://macro1.sharepoint.com/sites/ImplementacionSkype