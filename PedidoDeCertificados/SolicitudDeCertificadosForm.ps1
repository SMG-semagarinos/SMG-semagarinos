##################################################
#region Creacion del formulario
#
$FileXAML = "\\macro.com.ar\dfsmacro\My Document\smagarin\Documents\ProgramasVS\CertificadosPS_Form\CertificadosPS_Form\MainWindow.xaml"
$inputXML = Get-Content $FileXAML
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

#===========================================================================
# Convert To XML
#===========================================================================

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
  
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed." 
}
  
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables{
    if ($global:ReadmeDisplay -ne $true){
        Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true
    }
        Write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
        Get-Variable WPF*
}
  
$FormVariables = Get-FormVariables
#endregion
##################################################
$CurrentPath = Get-Location
Write-Host $CurrentPath -ForegroundColor Yellow
$EmailSolicitante = Get-ADUser $env:UserName -Properties EmailAddress
#Variables
$ServerContenedorCertificados = $WPFboxServerCont.Text
$FechaEjecucion = Get-Date -Format "ddMMyyyy_hhmmss"
$WPFboxFechaCreacion.Text = $FechaEjecucion 

#Enfocamos en la pimer TEXTBOX
$WPFboxCertificadoPara.Focus() | Out-Null

#region ######## Configuracion del boton PRE-SETEOS
$WPFbtnPreSetear.Add_MouseEnter({
    $Form.Cursor = [System.Windows.Input.Cursors]::Hand
    })

$WPFbtnPreSetear.Add_Click({ 
    Set-SMPreSetearDatos
    })

$WPFbtnPreSetear.Add_MouseLeave({
    $Form.Cursor = [System.Windows.Input.Cursors]::Arrow
    })
#endregion

#region ######## Configuracion del boton EDITAR
$WPFbtnEditar.Add_Click({ 
    #Preparacion de Variables
    Set-SMPreSetearDatos
    #Llenamos los campos
    Set-SMHabilitarEdicion
})

#endregion 

$WPFbtnSolicitarCertificado.Add_Click({
    Set-SMSolicitarCertificado
})

#region ### FUNCIONES
Function Set-SMHabilitarEdicion {
    $WPFboxEstado.Text = "Habilitamos Edicion..."
    If ($ModoEdicion -eq $false ) {
    $ModoEdicion = $true
    $WPFboxServerCont.IsEnabled = $true
    $WPFboxPathTemporal.IsEnabled = $true
    $WPFboxServerCont.IsEnabled = $true
    $WPFboxDescripcion.IsEnabled = $true
    $WPFboxCertName.IsEnabled = $true
    $WPFboxCN.IsEnabled = $true
    $WPFboxDNSSAN.IsEnabled = $true
    $WPFboxXMLtxt.IsEnabled = $true
    $WPFboxOU.IsEnabled = $true
    $WPFboxOrganizacion.IsEnabled = $true
    $WPFboxLocaly.IsEnabled = $true
    $WPFboxCountry.IsEnabled = $true
    $WPFboxCity.IsEnabled = $true

    } ElseIf ($ModoEdicion -eq $true) {
    $ModoEdicion = $false
    $WPFboxServerCont.IsEnabled = $false
    $WPFboxPathTemporal.IsEnabled = $false
    $WPFboxServerCont.IsEnabled = $false
    $WPFboxDescripcion.IsEnabled = $false
    $WPFboxCertName.IsEnabled = $false
    $WPFboxCN.IsEnabled = $false
    $WPFboxDNSSAN.IsEnabled = $false
    $WPFboxXMLtxt.IsEnabled = $false
    $WPFboxOU.IsEnabled = $false
    $WPFboxOrganizacion.IsEnabled = $false
    $WPFboxLocaly.IsEnabled = $false
    $WPFboxCountry.IsEnabled = $false
    $WPFboxCity.IsEnabled = $false

    } Else {
    Write-Host $ModoEdicion
    }
    Write-Host $ModoEdicion
}

Function Set-SMPreSetearDatos {
    $WPFboxEstado.Text = "PreSeteamosDatos..."
    #Preparacion de Variables
    $ServerAplicar = $WPFboxCertificadoPara.Text
    $CertName = "Cert SAN $($WPFboxCertificadoPara.Text)"
    $Descripcion = "Cert SAN $($WPFboxCertificadoPara.Text)"
    $CN = "$($WPFboxCertificadoPara.Text).macro.com.ar"
    $DNSSAN = "dns=$($WPFboxCertificadoPara.Text).macro.com.ar&dns=$($WPFboxCertificadoPara.Text)"
    #Llenamos los campos
    #$WPFboxServerCont.Text
    $WPFboxDescripcion.Text = $Descripcion
    $WPFboxCertName.Text = $CertName 
    $WPFboxCN.Text = $CN 
    $WPFboxDNSSAN.Text = $DNSSAN
    $OrgUnit = $WPFboxOU.Text
    $Org = $WPFboxOrganizacion.Text
    $Localidad = $WPFboxLocaly.Text
    $Pais = $WPFboxCountry.Text
    $Ciudad = $WPFboxCity.Text
    #Firma
    $Signature = '$Windows NT$'
    #CA
    $CertCATemplate = "MacroWebServerExportable"
    $SubjectCompleto = "CN=$CN, OU=$OrgUnit, O=$Org, L=$Localidad, S=$Ciudad, C=$Pais"
    $FriendlyName = "$CertName $FechaPedido"

#endregion

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

$WPFboxXMLtxt.Text = $INF

#endregion


#region Seteo de Paths
    $FolderNewCertificado = $WPFboxCertificadoPara.Text + $FechaEjecucion
    $WPFboxPathCertificados.Text = "\\macro.com.ar\dfsmacro\Servidores\SolicitudCertificados\$FolderNewCertificado\"

    $WPFboxPathRequest.Text = "Cert_Request_" + $ServerAplicar + "_" + $FechaEjecucion + ".req"
    $WPFboxPathRetrieveCER.Text = "Cert_Validacion_" + $ServerAplicar + "_" + $FechaEjecucion + ".cer"
    $WPFboxPathRetrieveRSP.Text = "Cert_Validacion_" + $ServerAplicar + "_" + $FechaEjecucion + ".rsp"
    $WPFboxPathPolicyPOL.Text = "Cert_Policy_" + $ServerAplicar + "_" + $FechaEjecucion + ".pol"
    $WPFboxPathPfx.Text = "Cert_ExportPfx_" + $ServerAplicar + "_" + $FechaEjecucion + ".pfx"
    $WPFboxPathPasswordPfx.Text = "Cert_ExportPfx_" + $ServerAplicar + "_" + $FechaEjecucion + ".psw"

    $WPFboxEstado.Text = "Crea CSR... " + $WPFboxPathPolicyPOL.Text + " y " + $WPFboxPathRequest.Text

Write-Host "Prepara PATHS" -ForegroundColor Red
#endregion
}

#$PathTemporal = "\\$ServerContenedorCertificados\E$\Scripts\Certificados\"

Function Set-SMSolicitarCertificado {

    #region Crear politica para crear el Request
    #Rutas de donde se dejan los archivos

    $ServerAplicar = $WPFboxCertificadoPara.Text 
    $FolderNewCertificado = $ServerAplicar + $FechaEjecucion
    $NewFolder = New-Item $WPFboxPathCertificados.Text  -ItemType Directory -Force
Invoke-Item $NewFolder
    $PathRequest = $WPFboxPathCertificados.Text + $WPFboxPathRequest.Text
    $PathRetrieveCER = $WPFboxPathCertificados.Text + $WPFboxPathRetrieveCER.Text
    $PathRetrieveRSP = $WPFboxPathCertificados.Text + $WPFboxPathRetrieveRSP.Text
    $PathPolicyPOL = $WPFboxPathCertificados.Text + $WPFboxPathPolicyPOL.Text 
    $PathPfx = $WPFboxPathCertificados.Text + $WPFboxPathPfx.Text
    $PathPassword = $WPFboxPathCertificados.Text + $WPFboxPathPasswordPfx.Text

    Set-Content -Path $PathPolicyPOL -Value $WPFboxXMLtxt.Text
Start-Sleep 20

Write-Host "Generada la politica" -ForegroundColor Green

    #endregion

    #region Genero el request localmente

    $CreaReq = Invoke-Command -ScriptBlock { CertReq -q -New $PathPolicyPOL $PathRequest }
    
Write-Host "Generado el request localmente " -ForegroundColor Green

    #endregion

    #region Envia el certificado a la CA 
    #
    $CACompleta = $WPFboxServerCA.Text
    $EnviaReq = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Submit $PathRequest }
    #
    $Regex = [Regex]::new('(?<=")(.*)(?=")')
    $Match = $Regex.Match($EnviaReq)            
    if($Match.Success)            
    {            
        $RequestID = $Match.Value
    }
Write-Host "Generado el request a la CA con el ID  $RequestID " -ForegroundColor Red
    #endregion

    #region Enviar E-Mail avisando del nuevo Certificado solicitado para su aprobacion.
    #
        $ParametrosMail = @{
        From = "Servidores, Solicitud de Certificado <servidores@macro.com.ar>"
        #To = "GSI-HBArq <gsai@macro.com.ar>"
        To = "SebastianMagarinos@macro.com.ar"
        CC = @("Servidores@macro.com.ar"; "SebastianMagarinos@macro.com.ar")
        BCC = "SebastianMagarinos@macro.com.ar"
        Subject = "Solicitud de Certificado | Request #$RequestID "
        #Attachments = ""
        SMTPServer = "smtp.macro.com.ar"
        BodyAsHTML = $True
        Priority = "High"
        }
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
    Write-Host "Enviando Email avisando del nuevo requerimiento  $RequestID " -ForegroundColor Green

    #endregion

    #region Descarga respuesta de la CA (LOOP)
    #
    $RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
        # Dejar intentando...
    $Intentos = 0
    Write-Host "Quedamos esperando respuesta del ID $RequestID " -ForegroundColor Red
    Do {
            $RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
            $Intentos++
            Write-Host "Vamos por el intento $Intentos" -ForegroundColor Yellow -NoNewline
            Remove-Item $PathRetrieveRSP
            Start-Sleep -Seconds 30
    }
    While ($RetrieCert -like "*Taken Under Submission (0)*")

    $RetrieCert = Invoke-Command -ScriptBlock { CertReq -Config $CACompleta -Retrieve $RequestID $PathRetrieveCER }
    Write-Host "Recibimos el certificado #$RequestID " -ForegroundColor Red

    Invoke-Item $PathTemporal

    #endregion

    #region Validar el certificado Solicitado
    $AcceptCert = Invoke-Command -ScriptBlock { CertReq -Accept $PathRetrieveCER }
    
Write-Host "Completamos el request #$RequestID " -ForegroundColor Green

    #endregion
    
    #region Export Certificado desde el server
    $PasswordPFX = ConvertTo-SecureString -String $WPFboxPassword.Text -Force -AsPlainText
    Set-Content -Path $PathPassword -Value $WPFboxPassword.Text 

    Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Export-PfxCertificate -FilePath $PathPfx -Password $PasswordPFX
#    Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Subject -eq $SubjectCompleto } | Remove-Item 

    Invoke-Item $PathCertificado    
Write-Host "Guardamos clave informada para el #$RequestID " -ForegroundColor Red


    #endregion

Write-Host "Finalizamos la solicitud y creacion" -ForegroundColor DarkBlue

}


#===========================================================================
# Shows the form
#===========================================================================

#[void] $Form.ShowDialog()

$Form.ShowDialog() | Out-Null


#Clear-Variable WPF*
#Remove-Variable WPF*

#endregion

