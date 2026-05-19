# Colecheck - Sistema Inteligente de Asistencia Escolar

Colecheck es una plataforma integral diseñada para modernizar y asegurar el control de asistencia en instituciones educativas. A través del escaneo de códigos QR y reconocimiento biométrico (proyectado), permite automatizar el registro de estudiantes, enviar notificaciones en tiempo real a los apoderados, y proveer un panel administrativo potente para la gestión del colegio.

## 🚀 Arquitectura del Proyecto

Este proyecto está construido bajo una arquitectura de **Monorepo** y se divide en tres módulos principales:

1. **API Backend (Node.js):** Servidor Express con Prisma + PostgreSQL que maneja autenticación (JWT), gestión de estudiantes, asistencia e incidencias.
2. **Panel Administrativo (Web):** Desarrollado con **React, Vite y TypeScript**, enfocado en la administración general (Directores, Seguridad Global, Administradores).
3. **Aplicación Móvil (Flutter):** Una única app nativa que utiliza **Control de Acceso Basado en Roles (RBAC)** para servir a dos tipos de usuarios:
   - **Padres/Apoderados:** Reciben notificaciones y revisan el historial de sus hijos.
   - **Personal de Control (Maestros/Guardias):** Escanean los códigos QR en las puertas y pueden registrar asistencia de forma manual.

---

## 🛠 Requisitos Previos

Antes de ejecutar el proyecto en tu máquina local, asegúrate de tener instalado:

- **Node.js** (v18 o superior) y **npm**.
- **Flutter SDK** (v3.19 o superior) configurado en tu PATH.
- **Docker** (para la base de datos PostgreSQL).
- (Opcional) Un emulador de Android/iOS o un dispositivo físico conectado.

---

## ⚙️ Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Blaydor09/colecheck.git
   cd colecheck
   ```

2. **Instalar dependencias globales (Monorepo):**
   *(Este comando instalará las dependencias de los módulos de Node.js, como la web y la API).*
   ```bash
   npm install
   ```

---

## 🗄️ Base de Datos y API Backend

**Paso obligatorio antes de ejecutar la web o la app móvil.**

1. Levanta la base de datos PostgreSQL:
   ```bash
   cd database
   docker compose up -d
   ```
2. Instala dependencias e inicia la API:
   ```bash
   cd apps/api
   npm install
   npm run dev
   ```
3. Verifica que la API esté corriendo: `http://localhost:3005/api/v1/health`

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
4. **Credenciales de prueba (Admin):**
   - **Correo:** `admin@colecheck.com`
   - **Contraseña:** `ADMIN123`

---

## 📱 Ejecución de la Aplicación Móvil (Padres y Personal)

La app móvil permite tanto la vista del Padre como la del Guardia desde una sola base de código.

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
   - El sistema detectará automáticamente tu rol según las credenciales:
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

