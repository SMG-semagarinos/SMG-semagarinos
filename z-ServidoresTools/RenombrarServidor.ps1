#Iniciamos log
$PathLog = ".\Logs\Transcript.log"
$PathLogGeneral = "C:\z-ServidoresTools\AccionesGenerales.log"
Start-Transcript -Path $PathLog -Append

#No restringido la ejecucion de scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

$ComputerNameCurrent = $env:computername

Write-Host "El nombre actual del equipo es: " -NoNewline -ForegroundColor Yellow
Write-Host $ComputerNameCurrent -ForegroundColor "Red"

$ComputerNameNew = Read-Host -Prompt "Porfavor ingresar el nuevo nombre del equipo"

If ($ComputerNameNew -eq "" -or $(Measure-Object -InputObject $ComputerNameNew -Character).Characters -lt "4"  ){
    Write-Host "Nombre Invalido $ComputerNameNew " -ForegroundColor Red
    Add-Content -Path $PathLogGeneral -Value "Error al intentar renombre $($env:computername)"
    #Write-Host "Presione un enter (2veces) para cerrar..." -NoNewline 
    Pause
}Else {
    Write-Host "Presione cualquier tecla para ejecutar cambio de nombre y reiniciar" -ForegroundColor Red
    Pause
    Add-Content -Path $PathLogGeneral -Value "Fecha: $(Get-date -Format "dddd dd/MM/yyyy") Nombre cambiado ( $($ComputerNameCurrent) ) a $($ComputerNameNew) "
    Rename-Computer -NewName $ComputerNameNew -Force -Restart
}

#Frenamos log y cerramos
Stop-Transcript
Exit