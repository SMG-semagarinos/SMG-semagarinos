#
# Seteos para envio de mails sin Skype for business
#
#Variables 
$ServidorScript = "$env:computername"
$Ejecutor = $env:UserName
$Ejecucion = (Get-date).ToString("dd/MM/yyyy HH:mm:ss")
#region Cuerpo del E-Mail
$Body = "
<head>
<meta charset='utf-8'>

<style>
	Table {
		margin-left: 65.0pt;
		border-collapse: collapse; 
		border: none; 
		border-spacing: 0;
	}
	th {
		width: 70pt;
		border-top: solid #BFBFBF 1.0pt;
		border-top: none;
		border-left: none;
		border-bottom: double #A5A5A5 1.5pt;
		border-right: solid #BFBFBF 1.0pt;
		background: #2E74B5;
		padding: 0cm 5.4pt 0cm 5.4pt;
		height: 5.7pt;
		color: white;
	}
	td {
		width: 148.45pt;
		border: solid #BFBFBF 1.0pt;
		background: #F2F2F2;
		padding: 0cm 5.4pt 0cm 5.4pt;
		height: 7.7pt;
	}
	td, th, table {
		font-size: 8pt;
		font-family: Verdana,sans-serif; 
		text-align: left
	}
	.ColIzquierda {
		text-align: right
	}
	.Texto {
		font-size: 8pt;
		font-family: Verdana,sans-serif; 
		color: gray;
	}
	.TextoHash{
		color: #2e75b6;
		font-style: italic;
	}
</style>

</head>
"
#Cuerpo del mensaje
$Body += $Message
#Tabla del contenido a informar.
$Body += $Tabla
 
#Firma del EMAIL ----------------------------
$Body += "
<p class='Texto'> Script generado a las <b> $Ejecucion </b> por el usuario <b> $Ejecutor </b> en el servidor <b> $ServidorScript </b> </p>

<b class='Texto'>Sistema de Solicitud de Certificados </b><span class='TextoHash'>#Servidores</span><br>
<span class='Texto'>Gerencia de Tecnologia</span><br>
<span class='Texto'>Banco Macro</span><br>
<span class='Texto'>Tel: (&#43;54) 11 5222 6500 Int: 28280 </span><br>
"

            
#endregion 

#region Envio de E-Mail
Send-MailMessage @ParametrosMail -Body $Body
#endregion 



