###########################################
#
# Instalacion de modulos POWERSHELL
#
###########################################


#region Configurar PROXY netsh
#Start-Process powershell_ise -verb runas
#Ver proxy a nivel WINDOWS
netsh winhttp show proxy
#Importar proxy de IE
netsh winhttp import proxy source=ie
#Credenciales
$webclient=New-Object System.Net.WebClient
$creds=Get-Credential
$webclient.Proxy.Credentials=$creds

#Limpiar proxy
netsh winhttp reset proxy
#endregion 

#region Actualizacion de libreria de Ayuda
Get-Culture
Update-Help
Update-Help -UICulture en-us -Force 
#endregion

#region Instalacion de modulo Office 365

Install-Module MSOnline 

Install-Module -Name AzureAD 
Install-Module -Name SqlServer

(Get-Module -ListAvailable SqlServer*).Path

Import-Module SQLServer
Install-Module PoshGram
#endregion

#region Instalacion de Modulos
Register-PSRepository -Default -Verbose
Get-PSRepository
Get-PackageProvider -ListAvailable
Find-Module VMware.PowerCLI | Install-Module
Find-Module IsilonPlatform | Install-Module
Install-Module -Name PoshProgressBar 
#endregion

#region Buscar Script de Certificado
Find-Script Request-Certificate 
Install-Script -Name Request-Certificate 
#endregion 

#region Instalacion de VMWare PowerCLI
Install-Module -Name VMware.PowerCLI -AllowClobber
#endregion



#region Instalacion de Modulos DNA


#Start-Process powershell_ise -verb runas
#Ver proxy a nivel WINDOWS
netsh winhttp show proxy
#Importar proxy de IE
netsh winhttp import proxy source=ie


$webclient=New-Object System.Net.WebClient
$creds=Get-Credential
$webclient.Proxy.Credentials=$creds


Register-PSRepository -Default -Verbose
#Get-PSRepository
#Get-PackageProvider -ListAvailable


Install-Module dbatools 

#Limpiar proxy
netsh winhttp reset proxy


#endregion



    Start-Process -execFilePath .\setup.exe -exec
    Start-Process -FilePath '.\setup.exe' -


            $startExe = new-object System.Diagnostics.ProcessStartInfo
            $startExe.FileName = 'C:\O365\setup.exe'
            $startExe.Arguments = '/download C:\O365\download-Office365-x64.xml'
            $startExe.CreateNoWindow = $false
            $startExe.UseShellExecute = $false

            $execStatement = [System.Diagnostics.Process]::Start($startExe) 
            $execStatement