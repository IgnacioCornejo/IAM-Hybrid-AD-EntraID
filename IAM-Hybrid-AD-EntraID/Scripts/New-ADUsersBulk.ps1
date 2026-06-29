#
.SYNOPSIS
    Crea usuarios en AD desde un archivo CSV (ABM - Altas)
.DESCRIPTION
    IAM Automation - User Provisioning
.NOTES
    Autor Proyecto IAM
#

$CsvPath = Cusuarios.csv
$LogPath = CLogscreacion_$(Get-Date -Format 'yyyyMMdd_HHmmss').log
$Dominio = empresa.local
$PasswordDefault = P@ssw0rd123!

New-Item -ItemType Directory -Force -Path CLogs  Out-Null

function Write-Log {
    param([string]$Mensaje, [string]$Nivel = INFO)
    $timestamp = Get-Date -Format yyyy-MM-dd HHmmss
    $linea = [$timestamp] [$Nivel] $Mensaje
    Write-Host $linea
    Add-Content -Path $LogPath -Value $linea
}

Write-Log Iniciando creacion masiva de usuarios INFO

$usuarios = Import-Csv -Path $CsvPath
Write-Log $($usuarios.Count) usuarios encontrados INFO

$creados = 0
$errores = 0
$omitidos = 0

foreach ($u in $usuarios) {
    $nombre = $($u.FirstName) $($u.LastName)
    $login = $($u.FirstName.Substring(0,1).ToLower())$($u.LastName.ToLower())
    $upn = $login@$Dominio
    $ouPath = OU=$($u.Department),OU=Usuarios,DC=empresa,DC=local
    $grupo = GRP-$($u.Department)

    Write-Log Procesando $nombre ($login) INFO

    $existe = Get-ADUser -Filter SamAccountName -eq '$login' -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Log Usuario ya existe $login WARNING
        $omitidos++
        continue
    }

    try {
        $password = ConvertTo-SecureString $PasswordDefault -AsPlainText -Force

        New-ADUser -Name $nombre `
                   -GivenName $u.FirstName `
                   -Surname $u.LastName `
                   -SamAccountName $login `
                   -UserPrincipalName $upn `
                   -DisplayName $nombre `
                   -Title $u.JobTitle `
                   -Department $u.Department `
                   -Office $u.Office `
                   -Path $ouPath `
                   -AccountPassword $password `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -ErrorAction Stop

        Write-Log Usuario creado $login SUCCESS
        $creados++

        try {
            Add-ADGroupMember -Identity $grupo -Members $login -ErrorAction SilentlyContinue
            Write-Log Agregado al grupo $grupo INFO
        } catch {
            Write-Log No se pudo agregar al grupo $grupo WARNING
        }

        if ($u.ManagerEmail) {
            $manager = Get-ADUser -Filter UserPrincipalName -eq '$($u.ManagerEmail)' -ErrorAction SilentlyContinue
            if ($manager) {
                Set-ADUser -Identity $login -Manager $manager.DistinguishedName
                Write-Log Manager asignado $($u.ManagerEmail) INFO
            } else {
                Write-Log Manager no encontrado $($u.ManagerEmail) WARNING
            }
        }

    } catch {
        Write-Log Error al crear $login  $($_.Exception.Message) ERROR
        $errores++
    }
}

Write-Log ========================================= INFO
Write-Log REPORTE FINAL INFO
Write-Log Total procesados $($usuarios.Count) INFO
Write-Log Usuarios creados $creados SUCCESS
Write-Log Omitidos (ya existian) $omitidos WARNING
Write-Log Errores $errores ERROR
Write-Log Log guardado en $LogPath INFO
Write-Log ========================================= INFO
