# 📋 Requerimientos del Backend

## 🔧 Configuraciones Necesarias

### 1. CORS (Cross-Origin Resource Sharing)
El backend debe permitir peticiones desde la aplicación móvil:

```javascript
// Ejemplo en Express.js
app.use(cors({
  origin: '*', // O especifica los orígenes permitidos
  credentials: true
}));
```

### 2. Formato de Respuestas

Todas las respuestas del backend deben seguir estos formatos:

#### Auth Endpoints

**POST /api/v1/auth/login**
```json
Request:
{
  "email": "rodrigo@gmail.com",
  "password": "hola123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "rodrigo@gmail.com",
    "name": "Rodrigo",
    "role": "admin",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**POST /api/v1/auth/register**
```json
Request:
{
  "email": "nuevo@usuario.com",
  "password": "password123",
  "name": "Nuevo Usuario",
  "role": "vendedor"  // Opcional, por defecto "vendedor"
}

Response (201):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "507f1f77bcf86cd799439012",
    "email": "nuevo@usuario.com",
    "name": "Nuevo Usuario",
    "role": "vendedor",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**GET /api/v1/auth/me**
```json
Headers:
{
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Response (200):
{
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "rodrigo@gmail.com",
    "name": "Rodrigo",
    "role": "admin",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Products Endpoints

**GET /api/v1/products**
```json
Query Parameters:
?search=nike&brand=Nike&color=Rojo&size=42

Response (200):
{
  "products": [
    {
      "_id": "507f1f77bcf86cd799439013",
      "name": "Nike Air Max 90",
      "brand": "Nike",
      "model": "Air Max 90",
      "color": "Rojo",
      "size": "42",
      "price": 129.99,
      "imageUrl": "https://ejemplo.com/imagen.jpg",
      "description": "Descripción del producto",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**GET /api/v1/products/:id**
```json
Response (200):
{
  "product": {
    "_id": "507f1f77bcf86cd799439013",
    "name": "Nike Air Max 90",
    "brand": "Nike",
    "model": "Air Max 90",
    "color": "Rojo",
    "size": "42",
    "price": 129.99,
    "imageUrl": "https://ejemplo.com/imagen.jpg",
    "description": "Descripción del producto",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**POST /api/v1/products** (Multipart/Form-Data)
```
Headers:
{
  "Authorization": "Bearer TOKEN",
  "Content-Type": "multipart/form-data"
}

Form Data:
- name: "Nike Air Max 90"
- brand: "Nike"
- model: "Air Max 90"
- color: "Rojo"
- size: "42"
- price: 129.99
- description: "Descripción" (opcional)
- imageUrl: "https://url.com" (opcional)
- image: [File] (opcional)

Response (201):
{
  "product": {
    "_id": "507f1f77bcf86cd799439013",
    "name": "Nike Air Max 90",
    ...
  }
}
```

**PATCH /api/v1/products/:id** (Multipart/Form-Data o JSON)
```
Igual que POST pero solo con los campos a actualizar

Response (200):
{
  "product": { ... }
}
```

**DELETE /api/v1/products/:id**
```json
Headers:
{
  "Authorization": "Bearer TOKEN (admin)"
}

Response (200):
{
  "message": "Producto eliminado exitosamente"
}
```

**PATCH /api/v1/products/:id/price**
```json
Request:
{
  "price": 149.99
}

Response (200):
{
  "product": { ... },
  "message": "Precio actualizado"
}
```

#### Services Endpoints

**POST /api/v1/services/import/excel**
```
Headers:
{
  "Authorization": "Bearer TOKEN (admin)",
  "Content-Type": "multipart/form-data"
}

Form Data:
- file: [Excel File]

Response (200):
{
  "products": [ ... array de productos importados ... ],
  "message": "Productos importados exitosamente"
}
```

**GET /api/v1/services/export/excel**
```json
Headers:
{
  "Authorization": "Bearer TOKEN"
}

Response (200):
{
  "url": "https://ejemplo.com/productos.xlsx"
  // O enviar el archivo directamente
}
```

**GET /api/v1/services/pdf/product/:id**
```json
Headers:
{
  "Authorization": "Bearer TOKEN"
}

Response (200):
{
  "url": "https://ejemplo.com/producto.pdf"
  // O enviar el archivo PDF directamente
}
```

## 🔐 Autenticación

### JWT Token
- El token debe ser válido por al menos 24 horas
- Debe incluir: `userId`, `email`, `role`
- Formato: `Bearer <token>`

### Roles
- **admin**: Acceso completo (CRUD productos, importar, exportar, etc.)
- **vendedor**: Solo lectura del catálogo

## 📝 Validaciones Requeridas

### Usuario
- Email: formato válido, único
- Password: mínimo 6 caracteres
- Name: requerido
- Role: solo "admin" o "vendedor"

### Producto
- Name: requerido, string
- Brand: requerido, string
- Model: requerido, string
- Color: requerido, string
- Size: requerido, string
- Price: requerido, número positivo
- ImageUrl: opcional, URL válida
- Description: opcional, string

## 📦 Formato de Excel para Importación

El archivo Excel debe tener estas columnas en el orden indicado:

| name | brand | model | color | size | price | imageUrl | description |
|------|-------|-------|-------|------|-------|----------|-------------|
| Nike Air Max | Nike | Air Max 90 | Rojo | 42 | 129.99 | https://... | Desc... |

## 🚨 Manejo de Errores

Todas las respuestas de error deben incluir:

```json
{
  "message": "Descripción del error",
  "error": "Detalles técnicos (opcional)"
}
```

### Códigos de Estado HTTP
- 200: OK
- 201: Created
- 400: Bad Request (validación fallida)
- 401: Unauthorized (no autenticado o token inválido)
- 403: Forbidden (no tiene permisos)
- 404: Not Found
- 500: Internal Server Error

## 🖼️ Manejo de Imágenes

### Subida de Imágenes
- Aceptar formato: multipart/form-data
- Formatos permitidos: JPG, JPEG, PNG
- Tamaño máximo: 5MB
- Retornar URL de la imagen subida

### URL de Imágenes
- Deben ser accesibles públicamente
- Preferiblemente usar HTTPS
- Soportar CORS

## 🔔 Notificaciones (Opcional)

Si implementas notificaciones de cambio de precio:

```json
POST /api/v1/products/:id/notify-price-change
{
  "oldPrice": 129.99,
  "newPrice": 149.99
}
```

## ✅ Checklist de Implementación

- [ ] Usuario admin creado: rodrigo@gmail.com / hola123
- [ ] CORS configurado
- [ ] JWT implementado
- [ ] Todos los endpoints funcionando
- [ ] Validaciones implementadas
- [ ] Manejo de errores correcto
- [ ] Imágenes funcionando (upload/display)
- [ ] Filtros de productos funcionando
- [ ] Importación de Excel
- [ ] Exportación de Excel
- [ ] Generación de PDF

## 🧪 Pruebas Recomendadas

Usa Postman o similar para probar:

1. Login con admin
2. Crear producto
3. Listar productos
4. Filtrar productos
5. Actualizar producto
6. Eliminar producto
7. Importar Excel
8. Exportar Excel
9. Generar PDF

---

**¿Necesitas ayuda con algún endpoint específico?** 
Puedes usar los formatos de arriba como referencia para implementar el backend.
