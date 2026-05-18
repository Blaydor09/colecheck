# Colecheck - Sistema Inteligente de Asistencia Escolar

Colecheck es una plataforma integral diseñada para modernizar y asegurar el control de asistencia en instituciones educativas. A través del escaneo de códigos QR y reconocimiento biométrico (proyectado), permite automatizar el registro de estudiantes, enviar notificaciones en tiempo real a los apoderados, y proveer un panel administrativo potente para la gestión del colegio.

## 🚀 Arquitectura del Proyecto

Este proyecto está construido bajo una arquitectura de **Monorepo** y se divide en dos aplicaciones principales:

1. **Panel Administrativo (Web):** Desarrollado con **React, Vite y TypeScript**, enfocado en la administración general (Directores, Seguridad Global, Administradores).
2. **Aplicación Móvil (Flutter):** Una única app nativa que utiliza **Control de Acceso Basado en Roles (RBAC)** para servir a dos tipos de usuarios:
   - **Padres/Apoderados:** Reciben notificaciones y revisan el historial de sus hijos.
   - **Personal de Control (Maestros/Guardias):** Escanean los códigos QR en las puertas y pueden registrar asistencia de forma manual.

---

## 🛠 Requisitos Previos

Antes de ejecutar el proyecto en tu máquina local, asegúrate de tener instalado:

- **Node.js** (v18 o superior) y **npm**.
- **Flutter SDK** (v3.19 o superior) configurado en tu PATH.
- (Opcional) Un emulador de Android/iOS o un dispositivo físico conectado.

---

## ⚙️ Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Blaydor09/colecheck.git
   cd colecheck
   ```

2. **Instalar dependencias globales (Monorepo):**
   *(Este comando instalará las dependencias de los módulos de Node.js, como la web).*
   ```bash
   npm install
   ```

---

## 💻 Ejecución del Panel Administrativo Web

El panel web te permite gestionar incidencias, revisar estadísticas globales en tiempo real y ver el directorio de estudiantes.

1. Navega a la carpeta de la web:
   ```bash
   cd apps/web
   ```
2. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```
3. Abre tu navegador y ve a `http://localhost:5173/`. 
*(Actualmente la app usa datos simulados (Mock Data) para demostrar la interactividad del sistema global de estados).*

---

## 📱 Ejecución de la Aplicación Móvil (Padres y Personal)

La app móvil permite simular tanto la vista del Padre como la del Guardia desde una sola base de código.

1. Navega a la carpeta de la app móvil:
   ```bash
   cd apps/mobile_app
   ```
2. Descarga las dependencias de Dart:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación (asegúrate de tener un emulador abierto o Chrome habilitado para Flutter Web):
   ```bash
   flutter run
   ```
4. **Flujo de Prueba en la App:**
   - La app abrirá la pantalla de Login con un formulario único.
   - El sistema detectará automáticamente tu rol según las siguientes credenciales estáticas de prueba:
     - **Acceso Padre/Apoderado:**
       - **Usuario/Correo:** `carlos@ejemplo.com`
       - **Contraseña:** `APP123`
     - **Acceso Personal/Escáner:**
       - **Usuario/Correo:** `fsalas@colecheck.com`
       - **Contraseña:** `PROF123`

---

## 📋 Documentación Adicional

En la carpeta `Docs/` encontrarás más información sobre los flujos del sistema y diagramas operativos de la lógica de asistencia y notificaciones.

*Colecheck - Safe & Calm Aesthetic UI v1.0*
