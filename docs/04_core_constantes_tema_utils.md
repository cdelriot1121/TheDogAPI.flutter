# 04 — Core: Constantes, Tema y Utilidades 🔧

> Los archivos de `core/` son los **cimientos** de toda la app. Todo lo que necesitan múltiples partes del proyecto vive aquí. En este documento analizamos los 3 archivos de `core/` línea por línea.

---

## Estructura de `core/`

```
lib/core/
├── constants/
│   └── api_constants.dart    ← URLs y configuración de la API
├── theme/
│   └── app_theme.dart        ← Tema visual: colores, estilos, componentes
└── utils/
    └── image_helper.dart     ← Helper para manejar imágenes (solución CORS en Web)
```

---

## 📄 `api_constants.dart` — Toda la configuración de la API

**Archivo:** [`lib/core/constants/api_constants.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/core/constants/api_constants.dart)

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.thedogapi.com/v1';
```

- `static` → no necesitas crear un objeto, se accede directo: `ApiConstants.baseUrl`
- `const` → es una constante en tiempo de compilación (nunca cambia)
- `baseUrl` → la raíz de todas las URLs de la API

---

```dart
  static const String apiKey = String.fromEnvironment(
    'DOG_API_KEY',
    defaultValue: '',
  );
```

**¿Qué hace `String.fromEnvironment`?**

Es una forma de **inyectar valores en tiempo de compilación** sin poner credenciales en el código fuente. Cuando compilas la app, puedes pasar la clave así:

```bash
flutter run --dart-define=DOG_API_KEY=tu_clave_real_aqui
```

Si no pasas nada, usa `''` (string vacío) como default. La API de TheDogAPI tiene un tier gratuito que funciona sin clave con límite de peticiones.

> **¿Por qué no poner la clave directo en el código?**
> Si subes el código a GitHub con tu clave hardcodeada, cualquier persona la puede ver y usar. Esto protege la clave.

---

```dart
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-api-key': apiKey,
  };
```

- `get` → es un getter (propiedad calculada). Se usa `ApiConstants.headers` sin `()`
- `=>` → es una función flecha (devuelve el mapa directamente)
- Los headers son lo que se envía junto a cada petición HTTP:
  - `Content-Type: application/json` → le dice a la API que enviamos/esperamos JSON
  - `x-api-key: tu_clave` → autenticación con TheDogAPI

---

```dart
  static String searchBreedsUrl(String query) =>
      '$baseUrl/breeds/search?q=$query';
  // Resultado: 'https://api.thedogapi.com/v1/breeds/search?q=Golden'

  static String imageDetailUrl(String imageId) =>
      '$baseUrl/images/$imageId';
  // Resultado: 'https://api.thedogapi.com/v1/images/BJa4kxc4X'

  static String imageUrlFromId(String imageId) =>
      'https://cdn2.thedogapi.com/images/$imageId.jpg';
  // Resultado: 'https://cdn2.thedogapi.com/images/BJa4kxc4X.jpg'
```

Estas 3 funciones centralizan la construcción de URLs. Si la API cambia su base URL, solo cambias `baseUrl` y el resto se actualiza automáticamente.

---

## 📄 `app_theme.dart` — El tema visual de la app

**Archivo:** [`lib/core/theme/app_theme.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/core/theme/app_theme.dart)

### Paleta de colores

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFFFF6F00);   // Naranja cálido
  static const Color secondaryColor = Color(0xFF3E2723); // Marrón oscuro
  static const Color accentColor = Color(0xFFFFB300);    // Ámbar brillante
  static const Color backgroundColor = Color(0xFFFBF9F5); // Crema suave
  static const Color cardColor = Colors.white;           // Blanco para tarjetas
  static const Color textPrimary = Color(0xFF1E1B18);    // Casi negro (texto principal)
  static const Color textSecondary = Color(0xFF6D655F);  // Gris cálido (texto secundario)
```

**Cómo leer los colores hex: `0xFFRRGGBB`**
- `0x` → prefijo hexadecimal en Dart
- `FF` → opacidad (FF = 255 = 100% opaco, 00 = transparente)
- `RR` → componente Rojo (00-FF)
- `GG` → componente Verde
- `BB` → componente Azul

Ejemplo: `0xFFFF6F00`:
- Opacidad: FF (100%)
- Rojo: FF (255 — máximo)
- Verde: 6F (111)
- Azul: 00 (0)
→ Resultado: naranja vivo 🟠

---

### El tema completo `lightTheme`

```dart
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,  // ← usa Material Design 3 (el más nuevo de Google)
```

`ThemeData` define cómo se ven **todos** los widgets de la app por defecto. Es como una "hoja de estilos global" (CSS) para toda la app.

---

```dart
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,    // ← genera una paleta a partir de este color
        primary: primaryColor,      // ← color principal
        secondary: secondaryColor,  // ← color secundario
        surface: cardColor,         // ← color de superficies (fondos de cards)
        brightness: Brightness.light, // ← modo claro
      ),
```

`ColorScheme` es el sistema de colores de Material 3. En lugar de definir cada color individualmente, defines un "color semilla" y Flutter genera toda la paleta armónica.

---

```dart
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,  // fondo crema
        elevation: 0,                      // sin sombra
        centerTitle: true,                 // título centrado
        scrolledUnderElevation: 2,         // sombra pequeña al hacer scroll
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
```

Con esto, **todas** las `AppBar` de la app heredan estos estilos sin que tengas que repetirlos en cada pantalla.

---

```dart
      cardTheme: CardThemeData(
        color: cardColor,           // fondo blanco
        elevation: 3,               // sombra
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // esquinas redondeadas
        ),
      ),
```

Todas las `Card` de la app tendrán bordes redondeados y esta sombra suave.

---

```dart
      inputDecorationTheme: InputDecorationTheme(
        filled: true,              // fondo relleno (blanco)
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),  // tipo "pill" (muy redondeado)
          borderSide: BorderSide.none,              // sin borde normal
        ),
        enabledBorder: OutlineInputBorder(          // borde cuando está inactivo
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.amber.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(          // borde cuando está seleccionado
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
      ),
```

Todos los `TextField` de la app tendrán este estilo de "pastilla" ovalada:
- Inactivo: borde ámbar suave
- Enfocado: borde naranja más grueso

---

```dart
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,   // naranja
          foregroundColor: Colors.white,   // texto blanco
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),  // botón redondeado
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
```

Todos los `ElevatedButton` serán naranjas con texto blanco y bordes redondeados.

---

### ¿Cómo se usa el tema en el proyecto?

```dart
// En main.dart
MaterialApp(
  theme: AppTheme.lightTheme,  // ← aplica el tema a toda la app
  // ...
)

// En cualquier pantalla, acceder a colores:
AppTheme.primaryColor    // naranja
AppTheme.textSecondary   // gris

// Obtener el tema actual desde un widget:
Theme.of(context).textTheme.titleLarge
```

---

## 📄 `image_helper.dart` — Solución al problema CORS en Web

**Archivo:** [`lib/core/utils/image_helper.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/core/utils/image_helper.dart)

```dart
import 'package:flutter/foundation.dart';

String getImageUrl(String? originalUrl) {
  if (originalUrl == null || originalUrl.isEmpty) {
    return '';
  }
  if (kIsWeb) {
    if (originalUrl.startsWith('https://corsproxy.io/?')) {
      return originalUrl;  // ya está usando proxy, no duplicar
    }
    return 'https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}';
  }
  return originalUrl;  // en móvil/desktop: usa la URL directa
}
```

### ¿Qué es CORS y por qué existe este helper?

**CORS** (Cross-Origin Resource Sharing) es una política de seguridad de los navegadores web. Cuando tu app web de Flutter intenta cargar una imagen del CDN de TheDogAPI (`cdn2.thedogapi.com`), el navegador bloquea la petición porque viene de un origen diferente.

**El problema:** `cdn2.thedogapi.com` no tiene los headers CORS configurados para permitir cargas desde webs externas.

**La solución:** Un proxy CORS. El helper redirige las peticiones a través de `corsproxy.io`, que actúa como intermediario:

```
Sin proxy (FALLA en web):
Browser → cdn2.thedogapi.com/images/abc.jpg
          ← ERROR: CORS blocked!

Con proxy (FUNCIONA en web):
Browser → corsproxy.io/?https%3A%2F%2Fcdn2.thedogapi.com%2Fimages%2Fabc.jpg
          → corsproxy.io → cdn2.thedogapi.com/images/abc.jpg
          ← imagen (con headers CORS correctos) ✓
```

### `kIsWeb` — detectar la plataforma

`kIsWeb` es una constante de Flutter que es `true` solo cuando la app corre en el navegador web.

```dart
if (kIsWeb) {
  // código solo para web
} else {
  // código para móvil/desktop
}
```

### `Uri.encodeComponent` — codificar URLs

Las URLs no pueden tener caracteres especiales (`:`, `/`, `?`, `&`). `Uri.encodeComponent` los convierte a formato seguro:

```dart
String url = 'https://cdn2.thedogapi.com/images/abc.jpg';
Uri.encodeComponent(url);
// → 'https%3A%2F%2Fcdn2.thedogapi.com%2Fimages%2Fabc.jpg'
```

---

### ¿Dónde se usa `getImageUrl`?

```dart
// En dog_card.dart
final imageUrl = getImageUrl(breed.imageUrl);
Image.network(imageUrl, ...)

// En dog_detail_screen.dart
final imageUrl = getImageUrl(rawImageUrl);
Image.network(imageUrl, ...)
```

Siempre que la app muestra una imagen de TheDogAPI, primero pasa por este helper para asegurarse de que funcione en todas las plataformas.

---

## Resumen del `core/`

| Archivo | Responsabilidad | Exporta |
|---------|----------------|---------|
| `api_constants.dart` | URLs y headers de la API | `ApiConstants` class |
| `app_theme.dart` | Tema visual global | `AppTheme` class con `lightTheme` y colores |
| `image_helper.dart` | URL de imágenes compatible con Web/CORS | `getImageUrl()` función |

---

*Siguiente: `05_modelos_de_datos.md` — BreedModel y DogImageModel 📦*
