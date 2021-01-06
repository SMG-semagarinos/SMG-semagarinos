#Iniciamos log
$PathLog = ".\Logs\Transcript.log"
$PathLogGeneral = "C:\z-ServidoresTools\AccionesGenerales.log"
#Start-Transcript -Path $PathLog -Append

#No restringido la ejecucion de scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

Rename-LocalUser -Name "Administrator" -NewName "adm_$env:computername"

#Stop-Transcript
pause