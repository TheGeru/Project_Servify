# project_servify

A new Flutter project.


# Integrantes:
- Dolores Abril Sánchez Camacho.
- Brandon Alonso Salinas
- Daniel Ulises Vazquez Hernandez.
- Ricardo Morales Sinecio

# 🛠️ Servify

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> Una aplicación web progresiva (PWA) que conecta profesionales con clientes, permitiendo la publicación y contratación de servicios y oficios.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Demo](#-demo)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Tecnologías](#️-tecnologías)
- [Prerequisitos](#-prerequisitos)
- [Instalación](#-instalación)
- [Configuración](#️-configuración)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API y Servicios](#-api-y-servicios)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)
- [Contacto](#-contacto)

## ✨ Características

### Para Profesionales
- 📝 **Publicación de Servicios**: Crea y gestiona anuncios de tus servicios profesionales
- 💼 **Perfil Profesional**: Muestra tu experiencia, portafolio y calificaciones
- 📊 **Panel de Control**: Administra tus servicios, solicitudes y estadísticas
- 💰 **Gestión de Precios**: Define tarifas personalizadas para tus servicios

### Para Clientes
- 🔍 **Búsqueda Avanzada**: Encuentra profesionales por categoría, ubicación y calificación
- ⭐ **Sistema de Reseñas**: Califica y comenta sobre servicios recibidos
- 📱 **Notificaciones**: Recibe actualizaciones sobre tus solicitudes
- 💬 **Chat Integrado**: Comunícate directamente con los profesionales

### Características Generales
- 🌐 **PWA**: Funciona como aplicación web progresiva en todos los dispositivos
- 🔐 **Autenticación Segura**: Sistema de login con Firebase Authentication
- 📸 **Galería de Trabajos**: Sube imágenes de trabajos realizados
- 🗺️ **Geolocalización**: Encuentra servicios cercanos a tu ubicación
- 🌙 **Modo Oscuro**: Interfaz adaptable a preferencias del usuario
- 📱 **Responsive**: Diseño optimizado para móvil, tablet y escritorio

## 🎥 Demo

🚀 **[Ver Demo en Vivo](#)** *(Agrega aquí tu URL de producción)*

## 📱 Capturas de Pantalla

*(Agrega aquí capturas de pantalla de tu aplicación)*

```
[Pantalla Principal] [Búsqueda] [Perfil] [Chat]
```

## 🛠️ Tecnologías

### Frontend
- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **Material Design** - Sistema de diseño

### Backend & Servicios
- **Firebase Authentication** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos en tiempo real
- **Firebase Storage** - Almacenamiento de imágenes
- **Firebase Cloud Messaging** - Notificaciones push
- **Firebase Hosting** - Deploy de la PWA

### Paquetes Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  firebase_messaging: ^latest
  provider: ^latest # Gestión de estado
  google_maps_flutter: ^latest # Mapas
  image_picker: ^latest # Selección de imágenes
  cached_network_image: ^latest # Caché de imágenes
```

## 📦 Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 o superior)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- Git

Verifica la instalación:
```bash
flutter --version
dart --version
firebase --version
```

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/TheGeru/Project_Servify.git
cd Project_Servify
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### a. Crear un proyecto en Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Habilita los servicios necesarios:
   - Authentication (Email/Password, Google)
   - Cloud Firestore
   - Storage
   - Cloud Messaging

#### b. Configurar para Web
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase en tu proyecto
flutterfire configure
```

#### c. Descargar archivos de configuración
- Descarga `google-services.json` para Android
- Descarga `GoogleService-Info.plist` para iOS
- La configuración web se genera automáticamente

### 4. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
FIREBASE_API_KEY=tu_api_key
FIREBASE_AUTH_DOMAIN=tu_auth_domain
FIREBASE_PROJECT_ID=tu_project_id
FIREBASE_STORAGE_BUCKET=tu_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=tu_sender_id
FIREBASE_APP_ID=tu_app_id
```

## ⚙️ Configuración

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Reglas para servicios
    match /services/{serviceId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.ownerId;
    }
    
    // Reglas para reseñas
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    
    match /services/{serviceId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🎯 Uso

### Modo Desarrollo

```bash
# Ejecutar en Chrome (recomendado para PWA)
flutter run -d chrome

# Ejecutar en modo debug con hot reload
flutter run --debug

# Ejecutar en dispositivo Android
flutter run -d android

# Ejecutar en dispositivo iOS
flutter run -d ios
```

### Build para Producción

#### Web (PWA)
```bash
# Build optimizado para web
flutter build web --release

# Los archivos estarán en: build/web/
```

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### Deploy

#### Firebase Hosting (PWA)
```bash
# Inicializar Firebase Hosting
firebase init hosting

# Deploy a producción
firebase deploy --only hosting
```

## 📁 Estructura del Proyecto

```
Project_Servify/
├── android/                # Configuración Android
├── ios/                    # Configuración iOS
├── lib/
│   ├── main.dart          # Punto de entrada
│   ├── config/            # Configuraciones
│   │   ├── theme.dart     # Tema de la app
│   │   └── routes.dart    # Rutas de navegación
│   ├── models/            # Modelos de datos
│   │   ├── user.dart
│   │   ├── service.dart
│   │   └── review.dart
│   ├── providers/         # Gestión de estado
│   │   ├── auth_provider.dart
│   │   ├── service_provider.dart
│   │   └── user_provider.dart
│   ├── screens/           # Pantallas de la app
│   │   ├── home/
│   │   ├── auth/
│   │   ├── profile/
│   │   ├── services/
│   │   └── chat/
│   ├── widgets/           # Componentes reutilizables
│   │   ├── service_card.dart
│   │   ├── user_avatar.dart
│   │   └── custom_button.dart
│   ├── services/          # Servicios y APIs
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── storage_service.dart
│   └── utils/             # Utilidades
│       ├── constants.dart
│       ├── helpers.dart
│       └── validators.dart
├── web/                   # Configuración PWA
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── test/                  # Tests
├── assets/                # Recursos estáticos
│   ├── images/
│   └── fonts/
├── pubspec.yaml          # Dependencias
├── .env                  # Variables de entorno
├── .gitignore
├── firebase.json         # Configuración Firebase
└── README.md
```

## 🔌 API y Servicios

### Modelos de Datos

#### Usuario
```dart
class User {
  String id;
  String name;
  String email;
  String? photoUrl;
  String? phone;
  UserType type; // CLIENT, PROFESSIONAL
  DateTime createdAt;
}
```

#### Servicio
```dart
class Service {
  String id;
  String title;
  String description;
  String category;
  double price;
  String ownerId;
  List<String> images;
  Location location;
  double rating;
  DateTime createdAt;
}
```

#### Reseña
```dart
class Review {
  String id;
  String serviceId;
  String userId;
  int rating;
  String comment;
  DateTime createdAt;
}
```

### Endpoints de Firebase

- **Authentication**: `/users/{userId}`
- **Servicios**: `/services/{serviceId}`
- **Reseñas**: `/reviews/{reviewId}`
- **Conversaciones**: `/chats/{chatId}`
- **Notificaciones**: `/notifications/{notificationId}`

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ejecutar tests de integración
flutter test integration_test/
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor, sigue estos pasos:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: nueva característica increíble'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guía de Estilo

- Sigue las [convenciones de Dart](https://dart.dev/guides/language/effective-dart)
- Usa nombres descriptivos para variables y funciones
- Comenta código complejo
- Escribe tests para nuevas funcionalidades

### Commits Convencionales

- `feat:` Nueva característica
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Cambios de formato
- `refactor:` Refactorización de código
- `test:` Añadir o modificar tests
- `chore:` Tareas de mantenimiento

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

```
MIT License

Copyright (c) 2024 TheGeru

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

## 👥 Contacto

**TheGeru** - Desarrollador Principal

- GitHub: [@TheGeru](https://github.com/TheGeru)
- Email: [tu-email@example.com]
- LinkedIn: [Tu LinkedIn]

---

## 🙏 Agradecimientos

- Flutter Team por el increíble framework
- Firebase por los servicios backend
- La comunidad open source por los paquetes utilizados

## 📊 Estado del Proyecto

- ✅ Autenticación implementada
- ✅ Publicación de servicios
- ✅ Sistema de búsqueda
- ✅ Perfil de usuario
- 🚧 Chat en tiempo real (en desarrollo)
- 🚧 Sistema de pagos (planeado)
- 📋 Sistema de citas (planeado)

## 🐛 Problemas Conocidos

Consulta los [Issues](https://github.com/TheGeru/Project_Servify/issues) para ver problemas conocidos y reportar nuevos.

## 📈 Roadmap

- [ ] Implementar sistema de pagos con Stripe
- [ ] Agregar videollamadas para consultas
- [ ] Sistema de citas y calendario
- [ ] Aplicación móvil nativa
- [ ] Panel de administración
- [ ] Múltiples idiomas (i18n)

---

<div align="center">
  <p>Hecho con ❤️ por TheGeru</p>
  <p>⭐ Si te gusta este proyecto, dale una estrella en GitHub!</p>
</div>