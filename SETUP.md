# Guía de Configuración y Ejecución - Footloose Catalog

## Requisitos Previos

- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior
- Android Studio / VS Code
- Git

## Configuración Inicial

### 1. Instalar Dependencias

Ejecuta el siguiente comando en la terminal dentro de la carpeta del proyecto:

```bash
flutter pub get
```

### 2. Configurar URL del Backend

Abre el archivo `lib/core/constants/api_constants.dart` y cambia la URL base del backend:

```dart
static const String baseUrl = 'http://TU_URL_BACKEND'; // Cambia esto
```

**Ejemplos:**
- Para localhost: `http://10.0.2.2:3000` (Android Emulator)
- Para localhost: `http://localhost:3000` (iOS Simulator)
- Para servidor remoto: `https://api.tudominio.com`

### 3. Generar Código de Serialización

La aplicación usa `json_serializable` para la serialización de modelos. Ejecuta:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando generará los archivos `.g.dart` necesarios para los modelos.

## Ejecutar la Aplicación

### Opción 1: Con VS Code
1. Abre el proyecto en VS Code
2. Presiona F5 o usa el menú "Run > Start Debugging"

### Opción 2: Con Terminal
```bash
flutter run
```

### Opción 3: Para un dispositivo específico
```bash
flutter devices              # Ver dispositivos disponibles
flutter run -d <device-id>   # Ejecutar en dispositivo específico
```

## Credenciales de Prueba

### Administrador (Acceso Completo)
- **Email:** rodrigo@gmail.com
- **Password:** hola123

### Usuario Vendedor
Puedes crear nuevos usuarios vendedores desde la pantalla de registro. Los vendedores pueden:
- Ver el catálogo de productos
- Buscar y filtrar productos
- Ver detalles de productos

Los administradores además pueden:
- Crear, editar y eliminar productos
- Importar productos desde Excel
- Exportar productos a Excel
- Generar PDFs de productos

## Estructura de la Aplicación

```
lib/
├── core/                   # Configuración base
│   ├── constants/         # Constantes (API, Strings, Storage)
│   ├── theme/            # Tema de la aplicación
│   ├── utils/            # Utilidades y helpers
│   ├── error/            # Manejo de errores
│   ├── routes/           # Rutas de navegación
│   └── di/               # Inyección de dependencias
│
├── data/                  # Capa de datos
│   ├── models/           # Modelos de datos
│   ├── datasources/      # Fuentes de datos (API, Local)
│   └── repositories/     # Repositorios
│
├── domain/               # Capa de dominio
│   └── entities/        # Entidades del negocio
│
└── presentation/         # Capa de presentación
    ├── bloc/            # BLoC (Gestión de estado)
    ├── screens/         # Pantallas de la app
    └── widgets/         # Widgets reutilizables
```

## Características Implementadas

### Autenticación
- Login con email y password
- Registro de nuevos usuarios (rol vendedor por defecto)
- Gestión de sesión con tokens
- Validación de formularios
- Almacenamiento seguro de credenciales

### Catálogo de Productos
- Lista de productos con scroll infinito
- Búsqueda por nombre
- Filtros por marca, color y talla
- Vista detallada de cada producto
- Carga de imágenes desde URL o dispositivo

### Funcionalidades de Administrador
- CRUD completo de productos
- Importación masiva desde Excel
- Exportación a Excel
- Generación de PDFs de productos
- Actualización de precios

### UI/UX
- Diseño moderno y responsivo
- Animaciones y transiciones suaves
- Feedback visual (loading, errores, éxitos)
- Caché de imágenes
- Pull to refresh

## Endpoints del Backend Utilizados

### Autenticación
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/register` - Registro
- `GET /api/v1/auth/me` - Obtener usuario actual

### Productos
- `GET /api/v1/products` - Listar productos (con filtros)
- `GET /api/v1/products/:id` - Obtener producto por ID
- `POST /api/v1/products` - Crear producto
- `PATCH /api/v1/products/:id` - Actualizar producto
- `DELETE /api/v1/products/:id` - Eliminar producto
- `PATCH /api/v1/products/:id/price` - Actualizar precio

### Servicios
- `POST /api/v1/services/import/excel` - Importar Excel
- `GET /api/v1/services/export/excel` - Exportar Excel
- `GET /api/v1/services/pdf/product/:id` - Generar PDF

## Solución de Problemas Comunes

### Error: "Target of URI doesn't exist"
**Solución:** Ejecuta `flutter pub get` para instalar las dependencias.

### Error: "Target of URI hasn't been generated"
**Solución:** Ejecuta el build_runner para generar los archivos:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error de conexión al backend
**Solución:** 
1. Verifica que el backend esté corriendo
2. Verifica la URL en `api_constants.dart`
3. Si usas emulador Android, usa `10.0.2.2` en lugar de `localhost`

### Imágenes no se cargan
**Solución:**
1. Verifica que el backend esté retornando URLs válidas
2. Si usas HTTP (no HTTPS), configura el AndroidManifest.xml:
   ```xml
   android:usesCleartextTraffic="true"
   ```

## Dependencias Principales

- **flutter_bloc**: Gestión de estado
- **dio**: Cliente HTTP
- **shared_preferences**: Almacenamiento local
- **cached_network_image**: Caché de imágenes
- **image_picker**: Selección de imágenes
- **file_picker**: Selección de archivos
- **excel**: Manejo de archivos Excel
- **pdf**: Generación de PDFs
- **get_it**: Inyección de dependencias
- **equatable**: Comparación de objetos

## Personalización

### Cambiar Colores
Edita `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF2196F3); // Cambia aquí
```

### Cambiar Textos
Edita `lib/core/constants/app_strings.dart`

## Soporte

Si encuentras algún problema o necesitas ayuda:
1. Verifica que todas las dependencias estén instaladas
2. Asegúrate de que el backend esté funcionando correctamente
3. Revisa los logs de la consola para mensajes de error

## Próximos Pasos

1. Configura tu URL del backend en `api_constants.dart`
2. Ejecuta `flutter pub get`
3. Ejecuta `flutter pub run build_runner build --delete-conflicting-outputs`
4. Ejecuta `flutter run`
5. Inicia sesión con las credenciales de administrador
6. ¡Disfruta de la aplicación!

---

**¡Listo para empezar!**
