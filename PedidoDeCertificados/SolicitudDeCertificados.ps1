##################################################
#
#
#
#
$ServerAplicar = "VCSA01-PROD"
$ServerContenedorCertificados = "SRVSERVAPP-PROD"
$CC = @("MaximilianoErbin@macro.com.ar")
#$Credentiales = Get-Credential
#$SessionPS = New-PSSession -ComputerName $ServerContenedorCertificados #-Authentication CredSSP -Credential $Credentiales
#Get-PSSession #| Remove-PSSession
##################################################
#region Configuracion para XML y paths
#
$CertName = "Cert SAN $ServerAplicar"
$Descripcion = "Cert SAN $ServerAplicar"
$CN = "$ServerAplicar.macro.com.ar"
$DNSSAN = "dns=$ServerAplicar.macro.com.ar&dns=$ServerAplicar"

#CrearPath
$FechaPedido = Get-Date -Format "ddMMyyyy_HHmmss"
$PathTemporal = "\\$ServerContenedorCertificados\E$\Scripts\Certificados\"
$FolderTemp = "$ServerAplicar$FechaPedido"
$NewFolder = New-Item -Path $PathTemporal -Name $FolderTemp -ItemType Directory 
$PathTemporal = "\\$ServerContenedorCertificados\E$\Scripts\Certificados\$FolderTemp\"
$PathCertCA = "\\Srvservapp-prod\e$\Scripts\Certificados\CA_Interna"
#Firma
$Signature = '$Windows NT$'
$OrgUnit = "Tecnologia IT"
$Org = "Banco Macro S.A."
$Localidad = "Ciudad de Buenos Aires"
$Ciudad = "Ciudad de Buenos Aires"
$Pais = "AR"
#CA
#$CertCATemplate = "MacroWebServerExportable"
$CertCATemplate = "MacroWebServerAuthMutua"

$CACompleta = "SRVPKIISSU-PROD.MACRO.COM.AR\MACRO-ISSUER"
#Rutas de donde se dejan los archivos
$PathRequest = $PathTemporal + "Cert_Request_" + $ServerAplicar + $FechaPedido + ".req"
$PathRetrieveCER = $PathTemporal + "Cert_Validacion_" + $ServerAplicar +  $FechaPedido + ".cer"
$PathRetrieveRSP = $PathTemporal + "Cert_Validacion_" + $ServerAplicar +  $FechaPedido + ".rsp"
$PathPolicyPOL = $PathTemporal + "Cert_Policy_" + $ServerAplicar + "_" + $FechaPedido + ".pol"
$PathPfx = $PathTemporal + "Cert_ExportPfx_" + $ServerAplicar + "_" + $FechaPedido + ".pfx"
$PathPassword = $PathTemporal + "Cert_ExportPfx_" + $ServerAplicar + "_" + $FechaPedido + ".psw"

$SubjectCompleto = "CN=$CN, OU=$OrgUnit, O=$Org, L=$Localidad, S=$Ciudad, C=$Pais"
$FriendlyName = "$CertName $FechaPedido" 
#endregion

##################################################
#region Genero el .inf para el certificado
$INF = @"
[Version]
Signature= "$Signature" 
 
[NewRequest]
Subject = "$SubjectCompleto"
FriendlyName = "$FriendlyName"
;Description = "$Descripcion"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 

[RequestAttributes] 
SAN = "$DNSSAN"
CertificateTemplate = $CertCATemplate

"@
#endregion

##################################################
#region Crear politica para crear el Request
#
Set-Content -Path $PathPolicyPOL -Value $INF

#endregion

##################################################
#region Genero el request | Mediante la SESSION REMOTA en el SRVSERVAPP-PROD
#
$CreaReq = Invoke-Command -ScriptBlock { CertReq -q -New $PathPolicyPOL $PathRequest } 
#endregion

##################################################
#region Envia el certificado a la CA | Mediante la SESSION REMOTA en el SRVSERVAPP-PROD
#
$EnviaReq = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Submit $PathRequest }

#Sin session
#$EnviaReq = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Submit $PathRequest }
#

$Regex = [Regex]::new('(?<=")(.*)(?=")')
$Match = $Regex.Match($EnviaReq)            
if($Match.Success)            
{            
    $RequestID = $Match.Value
}
Write-Host $RequestID -ForegroundColor Red
#endregion 

##################################################
#region Enviar E-Mail avisando del nuevo Certificado solicitado para su aprobacion.
#
cd "\\macro.com.ar\dfsmacro\My Document\smagarin\Documents\z-Scripts\SolicitudDeCertificados"

    $ParametrosMail = @{
    From = "Servidores, Solicitud de Certificado <servidores@macro.com.ar>"
    To = "GSI-HBArq <gsai@macro.com.ar>"
    CC = $CC
    BCC = "SebastianMagarinos@macro.com.ar"
    Subject = "Solicitud de Certificado | Request #$RequestID "
    SMTPServer = "smtp.macro.com.ar"
    BodyAsHTML = $True
    Priority = "High"
    }

    #Attachments = ""

    $Message = "
<p class='Texto'> <b>Estimados </b>por la presente les solicitamos la aprobacion del siguiente requerimiento <b>#$RequestID | $CertName </b>, les enviamos informacion de lo solicitado. </p>
"
    $Tabla = "
    <table> 
    <colgroup>
    <col>
    <col>
    </colgroup> 
    <tr>
    <th>Parametro</th>
    <th>Detalle</th>
    </tr> 
    <tr>
    <td>CN:</td>
    <td>$CN</td>
    </tr> 
    </table>
    "

    .\SolicitudDeCertificados_EnvioMail.ps1

#endregion

##################################################
#region Descarga respuesta de la CA
#

<#$RetrieCert = Invoke-Command -ScriptBlock { 
#Ejecuto accion:
    CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER
}

# Dejar intentando...
While ($RetrieCert -like "*Taken Under Submission (0)*") {
    Write-Host "Seguimos esperando el $RequestID"
    Start-Sleep -Seconds 300
    $RetrieCert = Invoke-Command -ScriptBlock { 
        #Ejecuto accion:
        CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER
    }

}
$RetrieCert
#>
# Dejar intentando... #>

    #region Descarga respuesta de la CA
    #
    #$RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
        # Dejar intentando...

    $Intentos = 0
    Do {
            $RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
            $Intentos++
            Write-Host "Vamos por el intento $Intentos"
            Remove-Item $PathRetrieveRSP
            Start-Sleep -Seconds 30
    }
    While ($RetrieCert -like "*Taken Under Submission (0)*")

    $RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
    

    Copy-Item -Path $PathCertCA -Destination $PathTemporal -Recurse -Force
    Invoke-Item $PathTemporal
    

    #endregion



#endregion 

##################################################
#region Validar el certificado Solicitado

$AcceptCert = Invoke-Command -ScriptBlock { CertReq -Accept $PathRetrieveCER }

#endregion

##################################################
#region Export Certificado desde el server.
#Exportar certificado
#ConvertTo-SecureString -String ‘1234’ -Force -AsPlainText

$PassTXT = "MacroCertificados2019"
$PasswordPFX = ConvertTo-SecureString -String $PassTXT -Force -AsPlainText

Set-Content -Path $PathPassword -Value $PassTXT

Invoke-Command -ScriptBlock {
    Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Export-PfxCertificate -FilePath $PathPfx -Password $PasswordPFX
    Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Remove-Item 
}

#endregion

##################################################
#region Eliminar sesion creada.
#Remove-PSSession $SessionPS
#endregion 


<# Importar Certificado en Servidor

$PassTXT = "MacroProduccion2018"
$PasswordPFX = ConvertTo-SecureString -String $PassTXT -Force -AsPlainText
$PathPfx  = "\\srvservapp-prod\e$\Scripts\Certificados\SRVVEREC05-PROD08082018_043212\Cert_ExportPfx_SRVVEREC05-PROD_08082018_043212.pfx"
Import-PfxCertificate -FilePath $PathPfx -CertStoreLocation Cert:\LocalMachine\My -Password $PasswordPFX -Exportable


#>


#<#Conversion de PFX to PEM.

#bin de OPENSSL
cd "C:\Program Files\OpenSSL-Win64\bin"
$PathPEMNoKey = $PathTemporal + "Cert_1PEMnokey_" + $ServerAplicar + "_" + $FechaPedido + ".pem" 
$PathPEMWithKey = $PathTemporal + "Cert_1PEMwithkey_" + $ServerAplicar + "_" + $FechaPedido + ".pem"
$PathKey = $PathTemporal + "Cert_1PEMkey_" + $ServerAplicar + "_" + $FechaPedido + ".key"
$PathCombo = $PathTemporal + "Cert_1PEMcombo_" + $ServerAplicar + "_" + $FechaPedido + ".pem"

Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -out $PathPEMNoKey -nokeys -password pass:$PassTXT" 2>&1
Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -out $PathPEMWithKey -passin pass:$PassTXT -passout pass:$PassTXT" 2>&1
Invoke-Expression ".\openssl rsa -in $PathPEMWithKey -out $PathKey -passin pass:$PassTXT -passout pass:$PassTXT" 2>&1

Get-Content $PathPEMNoKey > $PathCombo 
Get-Content $PathKey >> $PathCombo 
Invoke-Item $PathTemporal

#fin conversion
#>