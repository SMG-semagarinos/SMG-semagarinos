


$TotalMaibox = Get-mailbox * -ResultSize Unlimited 

($TotalMaibox | Where-Object { $_.ExchangeVersion -like "*8*" }).count

($TotalMaibox | Where-Object { $_.ExchangeVersion -like "*1*" }).count



$TotalMaibox | Where-Object { $_.ExchangeVersion -like "*8*" } | Select Identity | Export-Csv C:\z-FileSM\Ex2007.csv