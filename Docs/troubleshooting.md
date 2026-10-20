# Guía de Solución de Problemas (Troubleshooting)

Esta guía documenta los errores más comunes que pueden surgir durante la administración del entorno híbrido y cómo resolverlos.

## 1. Error: El script de PowerShell no se ejecuta
**Síntoma:** Al intentar correr un script, PowerShell muestra un error indicando que la ejecución de scripts está deshabilitada.
**Solución:** Ejecutar PowerShell como Administrador y cambiar la política de ejecución con el siguiente comando:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

## 2. Error: Usuario no puede iniciar sesión
**Síntoma:** El usuario intenta loguearse en la red o en la nube y recibe un error de credenciales.
**Solución:**
- Verificar que la cuenta esté habilitada en Active Directory.
- Si olvidó la contraseña, restablecerla desde Active Directory Users and Computers (ADUC).
- Si el usuario está bloqueado, desbloquear la cuenta desde la pestaña "Account" en sus propiedades.

## 3. Error: Los usuarios no aparecen en Microsoft Entra ID
**Síntoma:** Se crearon usuarios en el AD local pero no se reflejan en el portal de Azure.
**Solución:**
- Abrir PowerShell en el servidor DC01 y verificar el estado de la sincronización ejecutando: Get-ADSyncScheduler.
- Si la última sincronización fue hace mucho tiempo, forzar un ciclo manual ejecutando: Start-ADSyncSyncCycle -PolicyType Delta.
- Verificar que el servicio "Microsoft Entra Sync" esté corriendo en services.msc.

## 4. Advertencia: Certificado de Entra Connect expirado
**Síntoma:** La consola muestra el error AADSTS700027 indicando que el certificado expiró y no se puede sincronizar.
**Solución:**
- Descargar la última versión del instalador de Microsoft Entra Connect.
- Ejecutar el asistente y actualizar la herramienta. Esto renovará automáticamente el certificado de autenticación.
- Alternativamente, usar la opción "Rotate Application Certificate" dentro de las tareas adicionales de Entra Connect.
