$Password = Read-Host "Ingresar nueva password" -AsSecureString

if($Password.Length -eq 0 -or $Password.Length -lt 6 ){
    Write-Host "Sin password seteada correctamente, se pondra la basica Servidores2012"
    $UserAccount = Get-LocalUser -Name "Administrator"

    $Password = ConvertTo-SecureString -String "Servidores2012" -Force -AsPlainText
    $UserAccount | Set-LocalUser -Password $Password

}else {
    
    $UserAccount = Get-LocalUser -Name "Administrator"
    $UserAccount | Set-LocalUser -Password $Password

}

Pause
