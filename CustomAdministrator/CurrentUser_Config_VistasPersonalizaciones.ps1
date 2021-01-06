
Set-Location HKCU:\

$Registro = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Get-ItemProperty -Path $Registro -Name "HideFileExt"
#0 = show file extensions
#1 = hide file extensions
Set-ItemProperty -Path $Registro -Name "HideFileExt" -Value 0


$Registro = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Get-ItemProperty -Path $Registro -Name "Hidden"
#0 = show hidden files
#1 = don’t show hidden files
Set-ItemProperty -Path $Registro -Name "Hidden" -Value 0


$Registro = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Get-ItemProperty -Path $Registro -Name "LaunchTo"
#2 = Seteo para ver recientes.
#1 = para ver unidades y documentos.
Set-ItemProperty -Path $Registro -Name "LaunchTo" -Value 1


Pause