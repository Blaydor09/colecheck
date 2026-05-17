# Diagrama de Flujo del Sistema Colecheck

Este documento detalla la estructura y el flujo de trabajo del sistema Colecheck, basado en el diagrama proporcionado. El sistema se divide en tres perfiles principales de usuario que interactúan con la plataforma de diferentes maneras.

## Inicio del Flujo
**Punto de entrada:** "Usuario entra a la aplicación" -> **Decisión:** "¿Quién eres?"

A partir de aquí, el flujo se divide en tres ramas principales según el rol del usuario:

### 1. Colegio / Administrador (Rama Izquierda)
Este rol interactúa principalmente con el **Panel Administrativo (Web)**.

*   **¿Primera vez?**
    *   **Sí:** Configuración Inicial.
        *   Registrar estudiantes.
        *   Registrar profesores/personal.
        *   Configurar horarios.
        *   Configurar notificaciones.
    *   **No:** Acceso directo al Dashboard Principal.
        *   Ver estadísticas generales.
        *   Reportes históricos.
*   **Gestión Continua (Panel de Control)**
    *   Ver reportes de ingresos y salidas diarios.
    *   Generar alertas manuales.
    *   Monitorear asistencia en tiempo real.
*   **¿Hay Incidencias?**
    *   **Sí:** Sección "Resolver Incidencias" (Ej: Justificar faltas, editar registros manuales, contactar padres). -> Termina en "Exportar reportes y continuar".
    *   **No:** Exportar reportes y continuar.
*   **Fin del flujo administrativo.**

### 2. Padres / Apoderados (Rama Central)
Este rol interactúa principalmente con la **Aplicación Móvil**.

*   **¿Primera vez?**
    *   **Sí:** Configuración de la App.
        *   Crear cuenta / Iniciar sesión.
        *   Vincular estudiante(s) (mediante código o DNI).
        *   Configurar preferencias de notificaciones.
    *   **No:** Acceso a la Pantalla Principal (Ver asistencia y alertas).
*   **Interacción Diaria**
    *   **¿Hay alertas/notificaciones?**
        *   El padre recibe notificaciones (Ingreso/Salida/Falta/Retraso).
        *   Puede revisar el detalle de la alerta.
    *   **Revisar Historial:**
        *   Ver historial de asistencia del mes.
        *   Justificar faltas (enviar solicitud al administrador).
*   **Fin del flujo del apoderado.**

### 3. Personal de Control / Asistencia (Rama Derecha)
Este rol es el encargado de registrar la asistencia in-situ (en la puerta del colegio o aula).

*   **Acción Inicial:** Estudiante llega al colegio.
*   **Decisión:** ¿El estudiante trae su credencial/código QR (o celular)?
    *   **Sí:** 
        *   **Escanear QR de estudiante.**
        *   **¿Es válido?**
            *   *Sí:* El sistema registra la asistencia (Ingreso).
            *   *No:* El sistema rechaza el código -> Pasa a Registro Manual.
    *   **No:**
        *   Pasa a **Registro Manual**.
*   **Registro Manual (Flujo Alternativo / Checklist):**
    *   El personal busca al estudiante en la lista.
    *   Marca su estado manualmente (Presente, Ausente, Retraso).
*   **Proceso post-registro:**
    *   El sistema procesa la información en la base de datos.
    *   Se disparan notificaciones automáticas a los Padres (vía App/SMS).
    *   El registro se refleja en el Panel Administrativo.
*   **Flujo de Salida:**
    *   Estudiante sale del colegio.
    *   Se repite el proceso (Escanear QR o Registro Manual).
    *   Notificación de salida a los padres.
*   **Fin del flujo de control.**

---
*Nota: Este flujo representa la lógica de negocio central de Colecheck, asegurando que todos los actores (Admin, Padres, Control) estén conectados en tiempo real.*
