##### 
#
#
# Unrestricted para ejecutar el script.
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

$ServerAplicar = "SRVDFRMAP-PROD"

$ServerContenedorCertificados = "SRVSERVAPP-PROD"

$CC = @("Servidores@macro.com.ar")
$CCO = @("SebastianMagarinos@macro.com.ar")
$IpAddress = ""

##################################################
#region Configuracion para XML y paths
#
$CertName = "Cert SAN $ServerAplicar"
$Descripcion = "Cert SAN $ServerAplicar"
$CN = "$ServerAplicar.macro.com.ar"

if ($IpAddress -eq "") {
    ##### Ip no declarada #
    $DNSSAN = "dns=$ServerAplicar.macro.com.ar&dns=$ServerAplicar"
}Else{
    #
    #Ip declarada
    $DNSSAN = "ipaddress=$IpAddress&dns=$IpAddress&dns=$ServerAplicar.macro.com.ar"
}

#Librerias/Binarios
$PathOpenSSL = "C:\Program Files\OpenSSL-Win64\bin"
$PathjavaBIN = "C:\Program Files\Java\jre1.8.0_261\bin"

#CrearPath
$FechaPedido = Get-Date -Format "ddMMyyyy_HHmmss"
$PathTemporal = "\\$ServerContenedorCertificados\E$\Scripts\Certificados\"
$FolderTemp = $ServerAplicar + "_" + $FechaPedido
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
$CertCATemplate = "MacroWebServerExportable"
#$CertCATemplate = "MacroWebServerAuthMutua"
#$CertCATemplate = "MacroClientAuth"

$CACompleta = "SRVPKIISSU-PROD.MACRO.COM.AR\MACRO-ISSUER"
#Rutas de donde se dejan los archivos
$PathRequest = $PathTemporal + "Cert_Request_" + $ServerAplicar + "_" + $FechaPedido + ".csr"
$PathRetrieveCER = $PathTemporal + "Cert_Validacion_" + $ServerAplicar + "_" +  $FechaPedido + ".cer"
$PathRetrieveRSP = $PathTemporal + "Cert_Validacion_" + $ServerAplicar + "_" +  $FechaPedido + ".rsp"
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
OID=1.3.6.1.5.5.7.3.1 ; Server Authentication
OID=1.3.6.1.5.5.7.3.2 ; Client Authentication

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
#region Genero el request (CSR)
#
$CreaReq = Invoke-Command -ScriptBlock { CertReq -q -New $PathPolicyPOL $PathRequest } 
#endregion


# Validar contenido del CSR
Set-Location $PathOpenSSL
$TextRequest = @(Invoke-Expression ".\openssl.exe req -in $PathRequest -noout -text")
$ResumenCSR = $TextRequest | Select-String "Subject:", "Dns:"
$ResumenCSR = $ResumenCSR -replace "        ",""
Write-Host -ForegroundColor Yellow $ResumenCSR

##################################################
#region Envia el certificado a la CA 
#
$EnviaReq = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Attrib "CertificateTemplate:$CertCATemplate" -Submit $PathRequest  }

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
Set-Location "\\macro.com.ar\dfsmacro\My Document\smagarin\Documents\z-Scripts\SolicitudDeCertificados"

    $ParametrosMail = @{
    From = "Servidores, Solicitud de Certificado <servidores@macro.com.ar>"
    To = "GSI - Identidad y Acceso <GSI-IdentidadyAccesos@macro.com.ar>"
    CC = $CC
    BCC = $CCO
    Subject = "Solicitud de Certificado | Pedido #$RequestID "
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
# nos llevamos certificado de la CA.

Copy-Item -Path $PathCertCA -Destination $PathTemporal -Recurse -Force
# Dejar intentando...

$Intentos = 0

#REVISION
$RetrieveRSP = "Sin Solicitar"

Do {
    $Intentos++
    Write-Host "Esperando aprobacion del #$RequestID, re-intento " -NoNewline
    Write-Host $Intentos -ForegroundColor "Green"
    If (Test-Path $PathRetrieveCER ) {
        Remove-Item $PathRetrieveCER
    }ElseIf (Test-Path $PathRetrieveRSP ) { 
        Remove-Item $PathRetrieveRSP 
    }Else {
        $RetrieveRSP = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER}
    }
    Start-Sleep -Seconds 10
} Until ( $RetrieveRSP -like "*Issued*" )

Invoke-Item $PathTemporal

#endregion 

##################################################
#region Validar el certificado Solicitado en el equipo.

$AcceptCert = Invoke-Command -ScriptBlock { CertReq -Accept $PathRetrieveCER }

#endregion

##################################################
#region Generar archivo de Informacion de la solicitud de certificado
#<#
$PathInformacion = $PathTemporal + "Cert_Informacion_" + $ServerAplicar + "_" + $FechaPedido + ".info"

Set-Content -Path $PathInformacion -Value "Informacion de la solicitud de certificado."

$Informacion = @(

    "RequestID : $RequestID"
    "FechaPedido : $FechaPedido"
    "PathTemporal : $PathTemporal"
    "FolderTemp : $FolderTemp"
    "NewFolder : aksd"
    "PathCertCA : $PathCertCA"
""
    "OrgUnit : $OrgUnit"
    "Org : $Org"
    "Localidad : $Localidad"
    "Ciudad : $Ciudad"
    "Pais : $Pais"
    "CertCATemplate : $CertCATemplate"
""
    "CACompleta : $CACompleta"
    "PathRequest : $PathRequest"
    "PathRetrieveCER : $PathRetrieveCER"
    "PathRetrieveRSP : $PathRetrieveRSP"
    "PathPolicyPOL : $PathPolicyPOL"
    "PathPfx : $PathPfx"
    "PathPassword : $PathPassword"
""
    "SubjectCompleto : $SubjectCompleto"
    "FriendlyName : $FriendlyName"
    "DNS SAN: $DNSSAN"
)

$Informacion | ForEach-Object { Add-Content -Path  $PathInformacion -Value $_ }

#>
#endregion

##################################################
#region Export Certificado a PFX
#Exportar certificado y su password.
$PassTXT = "MacroCertificados2020"
$PasswordPFX = ConvertTo-SecureString -String $PassTXT -Force -AsPlainText

Set-Content -Path $PathPassword -Value $PassTXT

Invoke-Command -ScriptBlock {
    
    Try {
        Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Export-PfxCertificate -FilePath $PathPfx -Password $PasswordPFX
        Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Remove-Item
    }
    Catch {
      Write-Error "Problema al Exportar el CERTIFICADO PFX"  
    }

}

Write-Host "Esto es para ver la Huella del certificado." -ForegroundColor green
Write-Host "(Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } ).Thumbprint"
#endregion



#<#Conversion de PFX to PEM.
Set-Location $PathOpenSSL
$PathPEMNoKey = $PathTemporal + "Cert_1PEMnokey_" + $ServerAplicar + "_" + $FechaPedido + ".pem" 

$PathPEMWithKey = $PathTemporal + "Cert_1PEMwithkey_" + $ServerAplicar + "_" + $FechaPedido + ".pem"
$PathKey = $PathTemporal + "Cert_1PEMkey_" + $ServerAplicar + "_" + $FechaPedido + "_3.key"
$PathCombo = $PathTemporal + "Cert_1PEMcombo_" + $ServerAplicar + "_" + $FechaPedido + ".pem"
$PathPEM = $PathTemporal + "Cert_1PEM_" + $ServerAplicar + "_" + $FechaPedido + ".pem"

##############
$PathLinuxCRT = $PathTemporal + "Cert_Linux_" + $ServerAplicar + "_" + $FechaPedido + ".crt" 
Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -passin pass:$PassTXT -out $PathLinuxCRT -clcerts -nokeys " 2>&1

$PathLinuxKeyCrypt = $PathTemporal + "Cert_Linux_" + $ServerAplicar + "_" + $FechaPedido + ".keycrypt" 
Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -passin pass:$PassTXT -out $PathLinuxKeyCrypt -passout pass:$PassTXT -nocerts " 2>&1

$PathLinuxKey = $PathTemporal + "Cert_Linux_" + $ServerAplicar + "_" + $FechaPedido + ".key" 
Invoke-Expression ".\openssl.exe rsa -in $PathLinuxKeyCrypt -passin pass:$PassTXT -out $PathLinuxKey " 2>&1
##############
#
#Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -out $PathPEMNoKey -nokeys -password pass:$PassTXT" 2>&1
#Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -out $PathPEMWithKey -passin pass:$PassTXT -passout pass:$PassTXT" 2>&1
#
#Invoke-Expression ".\openssl.exe pkcs12 -in $PathPEMWithKey -passin pass:$PassTXT -out $PathKey -passout pass:$PassTXT" 2>&1
#Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -out $PathKey -passin pass:$PassTXT " 2>&1
#$PathCACert = $PathTemporal + "Cert_CA_" + $ServerAplicar + "_" + $FechaPedido + ".cer" 
#$CACert = Invoke-Command -ScriptBlock { certutil -CA MACRO-ISSUER $PathCACert }
#certutil -CA -?
#certutil -ca.chain $PathCACert
###
#$PathLinuxKey = $PathTemporal + "Cert_CRT_" + $ServerAplicar + "_" + $FechaPedido + ".keycrypt"
#
#Invoke-Expression ".\openssl.exe pkcs12 -in $PathPfx -passin pass:$PassTXT -out $PathPEM -nodes" 2>&1


#Get-Content $PathPEMNoKey > $PathCombo 
#Get-Content $PathKey >> $PathCombo 
Invoke-Item $PathTemporal

#Creacion del JKS | Es necesario el el JDK "https://www.java.com/es/download/win10.jsp"
Set-Location $PathjavaBIN

$PathKeystore = $PathTemporal + "Cert_KeyStore_" + $ServerAplicar + "_" + $FechaPedido + ".jks"
.\keytool.exe -importkeystore -srckeystore $PathPfx -srcstoretype pkcs12 -destkeystore $PathKeystore -deststoretype pkcs12 -srcstorepass "$PassTXT" -deststorepass "$PassTXT"
#.\keytool.exe -importkeystore -srckeystore $PathPfx -srcstoretype pkcs12 -destkeystore $PathKeystore -deststoretype JKS 

#Comprimir carpeta
Compress-Archive -Path $PathTemporal -DestinationPath "$PathTemporal$FolderTemp.zip" -Force
#fin conversion
#>
