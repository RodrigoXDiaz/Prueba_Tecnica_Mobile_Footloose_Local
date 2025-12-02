# Comandos Rápidos de Ejecución

## Inicio Rápido (3 pasos)

### 1. Instalar Dependencias
```bash
cd "c:\Users\PC\Desktop\Prueba Técnica Footloose-Flutter"
flutter pub get
```

### 2. Generar Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configurar Backend URL

Edita `lib/core/constants/api_constants.dart` línea 3:
```dart
static const String baseUrl = 'http://TU_URL_AQUI';
```

Ejemplos:
- Emulador Android: `http://10.0.2.2:3000`
- iOS Simulator: `http://localhost:3000`
- Servidor remoto: `https://api.tudominio.com`

### 4. Ejecutar
```bash
flutter run
```

## Login de Prueba

**Administrador:**
- Email: `rodrigo@gmail.com`
- Password: `hola123`

## Comandos Útiles

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ejecutar en dispositivo específico
```bash
flutter run -d <device-id>
```

### Limpiar proyecto
```bash
flutter clean
flutter pub get
```

### Generar build de release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Ver logs
```bash
flutter logs
```

## Solución Rápida de Errores

### Error: "build_runner"
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "dependencies"
```bash
flutter clean
flutter pub get
```

### Error: "conexión backend"
1. Verifica que el backend esté corriendo
2. Verifica la URL en `api_constants.dart`
3. Para Android Emulator usa `10.0.2.2` en lugar de `localhost`

## Archivos Importantes

- **Backend URL**: `lib/core/constants/api_constants.dart`
- **Tema/Colores**: `lib/core/theme/app_theme.dart`
- **Textos**: `lib/core/constants/app_strings.dart`
- **Main**: `lib/main.dart`

## Estructura del Proyecto

```
lib/
├── core/           # Configuración
├── data/           # API & Datos
├── domain/         # Entidades
└── presentation/   # UI
    ├── bloc/       # Estado
    ├── screens/    # Pantallas
    └── widgets/    # Componentes
```

## Checklist Pre-Ejecución

- [ ] Backend corriendo
- [ ] URL configurada en `api_constants.dart`
- [ ] `flutter pub get` ejecutado
- [ ] `build_runner` ejecutado
- [ ] Dispositivo/emulador conectado

## ¡Listo para Empezar!

Una vez completados los pasos:
1. La app se abrirá en el splash screen
2. Te llevará al login
3. Ingresa credenciales de admin
4. Explora el catálogo

---

**¿Problemas?** Revisa `SETUP.md` para guía detallada o `BACKEND_REQUIREMENTS.md` para configuración del backend.
