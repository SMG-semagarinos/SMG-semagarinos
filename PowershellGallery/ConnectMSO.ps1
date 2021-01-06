#Para darle PROXY al PowerShell
netsh winhttp show proxy
#Importar proxy de IE
netsh winhttp import proxy source=ie
#Credenciales de PROXY
$webclient=New-Object System.Net.WebClient
$CredencialesProxy=Get-Credential -Message "Usuario de RED para PROXY" -UserName "Macro\Ejemplo"
$webclient.Proxy.Credentials=$CredencialesProxy
netsh winhttp show proxy


#Para resetear la configuracion PROXY en WINSO
#netsh winhttp reset proxy
##

#Para Instalar los componentes
#Install-Module MSOnline 
#Install-Module Azure
#Get-PSRepository
#Register-PSRepository -Default -Verbose
#Get-ExecutionPolicy
#Set-ExecutionPolicy Unrestricted 



#Credenciales
$CredencialO365 = Get-Credential -UserName "Ejemplo@macro.com.ar" -Message "Ingresar Usuario/Password de Office365"

#Conectar a O365 sin Session con Modulos
Connect-MsolService -Credential $CredencialO365 

#Sin MFO (Doble Factor Auth) sin Modulos
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $CredencialO365 -Authentication Basic -AllowRedirection
Import-PSSession $Session

