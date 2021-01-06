#Detalle de la imagen logo pixel: 120x120 en BMP con Paint en 24-bits
$Registro = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
$PathLogo = "oemlogo.bmp"
$PathLogoDest = "C:\Windows\System32\"
Copy-Item -Path $PathLogo -Destination $PathLogoDest 
Set-ItemProperty -Path $Registro -Name "Logo" -Value "C:\Windows\System32\oemlogo.bmp"

Set-Location HKLM:\
Set-ItemProperty -Path $Registro -Name "Manufacturer" -Value "Banco Macro - Servidores"
Set-ItemProperty -Path $Registro -Name "Model" -Value "EquipoConBaseTemplate 2019 - 23/12/2019"
Set-ItemProperty -Path $Registro -Name "SupportHours" -Value "7hs a 20hs"
Set-ItemProperty -Path $Registro -Name "SupportPhone" -Value "5222-6500 Int. 28280"
Set-ItemProperty -Path $Registro -Name "SupportURL" -Value "https://www.macro.com.ar"



Pause