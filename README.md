# CyberCafe App Mobile

Aplicación móvil nativa del sistema de gestión integral para Cybercafé.

Este proyecto corresponde a la herramienta móvil diseñada exclusivamente para el rol de **Asistente** dentro del local. Su propósito principal es permitir la movilidad del empleado para verificar el estado físico de los equipos, habilitar computadoras y reportar daños en hardware directamente desde las instalaciones.

La aplicación está desarrollada en **Flutter** y consume la API REST central construida en Django.

---

## Tecnologías utilizadas

- Flutter SDK
- Dart
- Paquete `http` o `dio` para consumo de la API
- Manejo de estado (Provider, Riverpod o Bloc, según defina el equipo)
- Git / GitHub

---

## Requisitos

Antes de trabajar en este proyecto, se debe contar con:

- **Flutter SDK** instalado y configurado en las variables de entorno
- **Android Studio** (con SDK de Android) o **Visual Studio Code** con extensiones de Flutter y Dart
- Un emulador de Android configurado o un dispositivo físico con depuración USB activada
- Git instalado
- Acceso al repositorio del proyecto

---

## 1. Inicialización del proyecto

Para cumplir con la configuración de repositorios, se inicializó este cascarón base utilizando el comando `flutter create`.
Para comenzar a trabajar localmente, debes clonar el repositorio y descargar las dependencias.

Desde la terminal:

```bash
git clone https://github.com/CyberCafe-System/cybercafe-app-mobile.git
cd cybercafe-app-mobile
flutter pub get
```

---

## 2. Estructura del proyecto

Se recomienda utilizar una arquitectura limpia dentro de la carpeta `lib/` para separar la interfaz de usuario de la lógica de conexión con la API.

La estructura propuesta es:

```text
cybercafe-app-mobile/
│
├── android/             # Configuración nativa para Android
├── ios/                 # Configuración nativa para iOS
├── lib/
│   ├── main.dart        # Archivo principal y configuración de rutas
│   │
│   ├── core/            # Configuraciones globales, colores y constantes
│   │   └── api_config.dart
│   │
│   ├── models/          # Clases que mapean el JSON de la API a Dart
│   │
│   ├── screens/         # Pantallas principales de la interfaz
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── hardware_review_screen.dart
│   │
│   ├── services/        # Lógica de comunicación HTTP con Django
│   │
│   └── widgets/         # Componentes visuales reutilizables
│
├── pubspec.yaml         # Dependencias de Flutter
├── .gitignore
├── README.md
└── analysis_options.yaml
```

Esta separación garantiza que, si cambia algo en la API de Django, solo se necesite modificar la carpeta `services/` o `models/`, sin afectar el diseño de las pantallas en `screens/`.

---

## 3. Roles y permisos en la app móvil

A diferencia del sistema web, esta aplicación está restringida por rol:

- **Asistente:** Es el único rol diseñado para operar esta aplicación. Podrá visualizar los equipos activos, recibir alertas cuando el tiempo de una renta finalice y realizar el checklist de revisión física.

> El cajero y el administrador operan desde la plataforma web y no requieren el uso de esta app para sus funciones principales.

---

## 4. Módulos principales (Asistente)

### Monitoreo de tiempos
Pantalla que muestra las computadoras en uso y notifica cuando el tiempo de un cliente ha terminado.

### Revisión de equipos (Checklist)
Al finalizar una renta, la computadora queda bloqueada lógicamente. El asistente usará la app para verificar que el mouse, teclado, monitor y torre estén en buen estado antes de volver a marcarla como disponible.

### Reporte de daños
Si un componente falla o se daña, el asistente puede reportarlo desde la app, cambiando el estado del equipo a **Daños menores** o **Fuera de servicio** y dejando un comentario técnico.

---

## 5. Ejecutar el entorno de desarrollo

Para correr la aplicación en tu entorno local junto con el backend:

1. Asegúrate de tener un emulador abierto o un celular conectado.
2. Abre la terminal en la raíz del proyecto.
3. Ejecuta:

```bash
flutter run
```

### ⚠️ Conexión a la API local

Dado que la app corre en un dispositivo o emulador y el backend se ejecuta en tu PC en `127.0.0.1`, las direcciones IP cambian:

- **En emulador Android:** usa `http://10.0.2.2:8000/api/`
- **En dispositivo físico:** usa la IP local de tu máquina, por ejemplo: `http://192.168.1.X:8000/api/`

> Si ambos dispositivos están conectados a la misma red Wi‑Fi, esta configuración permite que la app se comunique con Django correctamente.

---

## 6. Arquitectura de comunicación

Al igual que el sistema web, la app móvil no se conecta directamente a la base de datos MySQL.

```text
┌─────────────────────────────────┐      ┌────────────────────────┐
│       App Móvil (Flutter)       │      │                        │
│                                 │      │     Django Backend     │
│  1. Interfaz nativa (Dart)      ├─────►│     (Puerto 8000)      │
│                                 │      │                        │
│  2. Petición HTTP (Dio/http)    │◄─────┤  Devuelve datos (JSON) │
│                                 │      └──────────┬─────────────┘
│  3. Provider actualiza la UI    │                 │
└─────────────────────────────────┘                 ▼
                                              Base de datos
                                                 (MySQL)
```

---

## 7. Estado actual del proyecto

Actualmente, el proyecto se encuentra en la etapa inicial de configuración.

Se ha establecido:

- La inicialización del repositorio con el cascarón base de Flutter
- La definición de la arquitectura de carpetas en `lib/`
- La restricción de alcance exclusivo para el módulo de control y revisión física de equipos del rol **Asistente**

---

## 8. Próximos pasos

El desarrollo móvil se integrará a partir de la fase 7 del proyecto:

1. Conexión de la pantalla de login con el endpoint de autenticación de Django.
2. Desarrollo de la UI del dashboard para visualizar computadoras activas y tiempos restantes.
3. Diseño de la interfaz de hardware con checklist de periféricos y reportes de estado.
4. Pruebas de QA finales simulando carga simultánea con la app móvil y el sistema web.

---

## Descripción breve

Este repositorio forma parte del sistema integral de Cybercafé y se enfoca en la experiencia móvil del negocio, priorizando una interfaz clara, funcional y ágil para la supervisión de equipos y la atención del personal del local.

Prompt guía para la metodología de trabajo, abierto a cambios
