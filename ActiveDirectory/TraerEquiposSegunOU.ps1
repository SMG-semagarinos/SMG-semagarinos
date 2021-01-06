## Traer equipos segun OU


Import-Module ActiveDirectory

$OUs =
'OU=Servidores,DC=macro,DC=com,DC=ar',
'CN=Computers,DC=macro,DC=com,DC=ar',
'OU=Domain Controllers,DC=macro,DC=com,DC=ar'

$ComputersProperties = @()
Foreach($OU in $OUs){
    $ComputersProperties += Get-ADComputer -Filter * -Properties * -SearchBase $OU
}

$ComputersProperties | Export-Csv -Path "C:\z-Transito\ServidoresAD.csv" -NoTypeInformation -Delimiter ";"

