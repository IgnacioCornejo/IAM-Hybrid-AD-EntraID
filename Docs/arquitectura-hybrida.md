# Arquitectura Híbrida: Active Directory + Microsoft Entra ID

## Visión General

Este proyecto implementa una solución de identidad híbrida que combina Active Directory (On-Premise) con Microsoft Entra ID (Cloud). El objetivo es unificar la gestión de identidades para que los usuarios puedan acceder tanto a recursos locales como a aplicaciones en la nube utilizando la misma cuenta y contraseña.

## Componentes del Entorno

### 1. Active Directory (On-Premise)
- **Servidor:** Windows Server 2022 (Virtualizado en VirtualBox)
- **Nombre del equipo:** DC01
- **Dominio:** empresa.local
- **Dirección IP:** 192.168.1.10 (Estática)
- **Estructura:** Organizada en Unidades Organizativas (OUs) por departamentos (Ventas, IT, RRHH, Finanzas, etc.).
- **Seguridad:** Implementación de RBAC (Role-Based Access Control) mediante grupos de seguridad.

### 2. Microsoft Entra Connect (Sincronización)
- **Herramienta:** Microsoft Entra Connect Sync
- **Modo de instalación:** Configuración rápida (Express Settings).
- **Método de autenticación:** Password Hash Sync (Sincronización de hash de contraseñas).
- **Frecuencia:** Automática (cada 30 minutos).

### 3. Microsoft Entra ID (Cloud)
- **Tenant:** empresa-prueba.onmicrosoft.com (Dominio de ejemplo)
- **Identidades:** Los usuarios creados en el AD local se sincronizan automáticamente a la nube.
- **Acceso:** Permite el inicio de sesión unificado para servicios de Microsoft 365 y otras aplicaciones SaaS.

## Flujo de Trabajo

1. El usuario es creado en el Active Directory local (vía script de PowerShell o manual).
2. El servicio de Entra Connect detecta el nuevo objeto.
3. La identidad y su contraseña se sincronizan de forma segura hacia Microsoft Entra ID.
4. El usuario ya puede iniciar sesión en la nube con las mismas credenciales locales.
