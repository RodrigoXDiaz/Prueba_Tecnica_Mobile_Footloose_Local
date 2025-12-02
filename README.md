# Footloose Catalog

<div align="center">

**Aplicación móvil de catálogo de productos con autenticación y gestión basada en roles**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Características](#características) • [Arquitectura](#arquitectura) • [Instalación](#instalación) • [Uso](#uso) • [Tecnologías](#tecnologías)

</div>

---

## Descripción

Footloose Catalog es una aplicación empresarial desarrollada en Flutter que permite la gestión integral de un catálogo de productos con sistema de roles, notificaciones push en tiempo real y herramientas avanzadas para administradores.

### Casos de Uso

- **Vendedores**: Consultar catálogo de productos, buscar y filtrar por marca/color/talla
- **Administradores**: Gestión completa CRUD, importación/exportación masiva Excel, generación de PDFs
- **Clientes**: Seguimiento de productos con notificaciones automáticas de cambios de precio

---

## Características

### Autenticación y Seguridad
- Sistema de login/registro con JWT tokens
- Gestión de sesiones persistentes
- Roles diferenciados (Admin/Vendedor)
- Almacenamiento seguro de credenciales

### Gestión de Productos
- Catálogo completo con imágenes optimizadas
- Búsqueda en tiempo real
- Filtros avanzados por marca, color y talla
- Vista detallada con especificaciones completas
- Caché de imágenes para mejor rendimiento

### Funcionalidades Administrativas
- CRUD completo de productos
- Importación masiva desde archivos Excel
- Exportación de catálogo a Excel
- Generación automática de fichas PDF
- Actualización masiva de precios
- Gestión de stock en tiempo real

### Notificaciones Push
- Notificaciones de cambio de precio
- Alertas de nuevos descuentos
- Sistema de preferencias personalizable
- Historial completo de notificaciones
- Integración con Firebase Cloud Messaging

### UI/UX
- Diseño moderno con colores corporativos FOOTLOOSE
- Animaciones fluidas y transiciones suaves
- Modo responsivo para diferentes dispositivos
- Pull-to-refresh en todas las listas
- Feedback visual para todas las acciones
- Placeholders inteligentes para imágenes

---

## Arquitectura

El proyecto implementa **Clean Architecture** con separación de capas y **BLoC** para gestión de estado:

```
lib/
├── core/                          # Configuración base
│   ├── constants/                 # Constantes (API, Strings, Storage)
│   │   ├── api_constants.dart
│   │   ├── app_strings.dart
│   │   └── storage_keys.dart
│   ├── theme/                     # Tema y estilos
│   │   └── app_theme.dart
│   ├── utils/                     # Utilidades y helpers
│   │   ├── format_helper.dart
│   │   ├── validators.dart
│   │   └── app_events.dart
│   ├── error/                     # Manejo de errores
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── routes/                    # Navegación
│   │   └── app_router.dart
│   ├── di/                        # Inyección de dependencias
│   │   └── injection.dart
│   └── services/                  # Servicios globales
│       └── firebase_messaging_service.dart
│
├── data/                          # Capa de datos
│   ├── models/                    # Modelos de datos con serialización
│   │   ├── product_model.dart
│   │   ├── user_model.dart
│   │   ├── notification_model.dart
│   │   └── ...
│   ├── datasources/               # Fuentes de datos
│   │   ├── remote/
│   │   │   └── api_service.dart
│   │   └── local/
│   │       └── storage_service.dart
│   └── repositories/              # Repositorios (implementación)
│       ├── auth_repository.dart
│       ├── product_repository.dart
│       └── notification_repository.dart
│
├── domain/                        # Capa de dominio
│   └── entities/                  # Entidades del negocio
│       ├── product_entity.dart
│       └── user_entity.dart
│
└── presentation/                  # Capa de presentación
    ├── bloc/                      # BLoC (Gestión de estado)
    │   ├── auth/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── product/
    │   └── notification/
    ├── screens/                   # Pantallas de la app
    │   ├── auth/
    │   │   └── auth_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── products/
    │   │   ├── product_list_screen.dart
    │   │   ├── product_detail_screen.dart
    │   │   └── product_form_screen.dart
    │   └── notifications/
    │       ├── notification_history_screen.dart
    │       └── notification_preferences_screen.dart
    └── widgets/                   # Widgets reutilizables
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── loading_widget.dart
        └── error_widget.dart
```

### Principios de Arquitectura

- **Separación de responsabilidades**: Cada capa tiene una responsabilidad específica
- **Inyección de dependencias**: Uso de GetIt para gestión de dependencias
- **Repository Pattern**: Abstracción de fuentes de datos
- **BLoC Pattern**: Gestión de estado reactiva y predecible
- **Clean Code**: Código limpio, documentado y mantenible

---

## Instalación

### Requisitos Previos

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/footloose-catalog.git
   cd footloose-catalog
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar archivos de serialización**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configurar URL del backend**
   
   Edita `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://TU_URL_BACKEND';
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Configuración Adicional

Para más detalles sobre configuración, consulta [SETUP.md](SETUP.md)

---

## Uso

### Credenciales de Prueba

#### Administrador
- **Email**: rodrigo@gmail.com
- **Password**: hola123

#### Crear Usuario Vendedor
Puedes registrar nuevos usuarios vendedores desde la pantalla de registro.

### Flujo de Trabajo

1. **Login**: Inicia sesión con las credenciales de administrador o vendedor
2. **Catálogo**: Explora el catálogo de productos con búsqueda y filtros
3. **Detalles**: Toca cualquier producto para ver información completa
4. **Admin** (solo administradores):
   - Crear/editar/eliminar productos
   - Importar productos desde Excel
   - Exportar catálogo a Excel
   - Generar fichas PDF de productos
5. **Notificaciones**: Recibe alertas de cambios de precio en tiempo real

### Inicio Rápido

Para comandos rápidos, consulta [QUICK_START.md](QUICK_START.md)

---

## Tecnologías

### Core
- **Flutter 3.0+**: Framework de desarrollo multiplataforma
- **Dart 3.0+**: Lenguaje de programación

### Gestión de Estado
- **flutter_bloc 8.1+**: Implementación BLoC pattern
- **equatable 2.0+**: Comparación de objetos

### Networking & Serialización
- **dio 5.4+**: Cliente HTTP robusto
- **retrofit 4.0+**: Cliente REST type-safe
- **json_annotation 4.8+**: Serialización JSON

### Almacenamiento
- **shared_preferences 2.2+**: Preferencias locales
- **flutter_secure_storage 9.0+**: Almacenamiento seguro

### UI & Recursos
- **cached_network_image 3.3+**: Caché de imágenes
- **image_picker 1.0+**: Selección de imágenes
- **file_picker 6.1+**: Selección de archivos
- **google_fonts 6.1+**: Fuentes personalizadas
- **intl 0.18+**: Internacionalización

### Documentos
- **pdf 3.10+**: Generación de PDFs
- **printing 5.11+**: Impresión de documentos
- **excel 4.0+**: Manipulación de archivos Excel

### Firebase
- **firebase_core 3.6+**: Inicialización Firebase
- **firebase_messaging 15.1+**: Notificaciones push

### Inyección de Dependencias
- **get_it**: Service locator pattern

---

## Endpoints del Backend

### Autenticación
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/register` - Registrar usuario
- `GET /api/v1/auth/me` - Obtener usuario actual

### Productos
- `GET /api/v1/products` - Listar productos (con filtros)
- `GET /api/v1/products/:id` - Obtener producto por ID
- `POST /api/v1/products` - Crear producto
- `PATCH /api/v1/products/:id` - Actualizar producto
- `DELETE /api/v1/products/:id` - Eliminar producto
- `PATCH /api/v1/products/:id/price` - Actualizar precio

### Servicios
- `POST /api/v1/services/import/excel` - Importar desde Excel
- `GET /api/v1/services/export/excel` - Exportar a Excel
- `GET /api/v1/services/pdf/product/:id` - Generar PDF

### Notificaciones
- `POST /api/v1/notifications/subscribe` - Suscribirse a notificaciones
- `GET /api/v1/notifications/history/:userId` - Historial de notificaciones
- `PATCH /api/v1/notifications/:id/read` - Marcar como leída

Para más detalles, consulta [BACKEND_REQUIREMENTS.md](BACKEND_REQUIREMENTS.md)

---

## Estructura de Datos

### Producto
```dart
class ProductEntity {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String color;
  final String size;
  final double price;
  final int? stock;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Usuario
```dart
class UserEntity {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;
  final String? token;
}
```

---

## Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: nueva característica'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

<div align="center">

**Hecho con Flutter**

</div>
