Connect-Exchange

$PathCSV = "C:\Users\smagarin\Desktop\BT_Internos.csv"
$PathCSV = "C:\Users\smagarin\Desktop\BTNueva1710.csv"
$CSV = Import-Csv $PathCSV -Delimiter ";"
$ErrorActionPreference = "Stop"

$Fallas = @()
ForEach ( $User in $CSV) {
    If(  $User.'Nombre Empleado' -eq "" ){
        Write-Host "Usuario Sin Interno:" $User.'Nombre Empleado' -ForegroundColor Green
    }else {
        Try {   
            $GetMailbox = Get-Recipient $User.'Nombre Empleado' | Select-Object  DisplayName, SamAccountName, Phone
            Set-User $User.'Nombre Empleado' -Phone $User.InternoMerge 
            Write-Warning "Usuario Modificado: $($User.'Nombre Empleado') Interno: $($User.InternoMerge) "
        }
        Catch { 
            Write-Host "Revisar el usuario:" $User.'Nombre Empleado' -ForegroundColor Red 
            $Fallas += $User.'Nombre Empleado'
        }

    }

}
Get-Recipient  | Select-Object  DisplayName, SamAccountName, Phone 

$Fallas | clip