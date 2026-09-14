# 06 — Servicio API y HTTP 🌐

> `DogApiService` es el **puente** entre la app y TheDogAPI. Aquí aprenderás cómo se hacen peticiones HTTP en Flutter, cómo manejar errores de red, timeouts, códigos de estado HTTP y excepciones personalizadas.

---

## ¿Qué es un "Service" en esta arquitectura?

Un **Service** es una clase responsable de hablar con fuentes de datos externas (APIs, bases de datos, archivos). En este proyecto, `DogApiService`:

- Hace peticiones HTTP a TheDogAPI
- Parsea las respuestas JSON a modelos Dart
- Maneja errores (timeout, errores de servidor, problemas de red)
- Lanza excepciones con mensajes descriptivos

---

## 📄 `dog_api_service.dart` — Línea por línea

**Archivo:** [`lib/features/dog_search/data/services/dog_api_service.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/data/services/dog_api_service.dart)

### Imports

```dart
import 'dart:convert';                         // para json.decode()
import 'package:http/http.dart' as http;       // paquete HTTP externo
import '../../../../core/constants/api_constants.dart';
import '../models/breed_model.dart';
import '../models/dog_image_model.dart';
```

- `dart:convert` → librería estándar de Dart para convertir JSON a objetos Dart
- `http` → paquete externo (declarado en `pubspec.yaml`) para peticiones HTTP
- `as http` → importa con alias para distinguirlo de otros "http" que pueda haber

---

### La excepción personalizada

```dart
class DogApiException implements Exception {
  final String message;
  final int? statusCode;

  DogApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
```

**¿Por qué crear una excepción personalizada?**

Dart tiene `Exception` genérico, pero crear `DogApiException` nos permite:
1. Identificar exactamente de qué tipo es el error (viene de la API)
2. Agregar información extra (`statusCode` = 404, 429, 500, etc.)
3. Mostrar mensajes amigables al usuario

`implements Exception` → implementa la interfaz estándar de excepciones de Dart.

`@override String toString()` → cuando haces `print(excepcion)` o `excepcion.toString()`, devuelve el mensaje legible.

---

### La clase `DogApiService`

```dart
class DogApiService {
  final http.Client _client;

  DogApiService({http.Client? client}) : _client = client ?? http.Client();
```

**`http.Client`** → Es la "conexión" HTTP reutilizable. Mejor que crear una nueva conexión para cada petición.

**¿Por qué recibe `http.Client?` como parámetro?**

Esto se llama **inyección de dependencias**. Permite:
- En producción: usa `http.Client()` real (hace peticiones reales)
- En tests: puedes pasar un `MockClient` que simula respuestas

```dart
DogApiService()                          // usa http.Client() real
DogApiService(client: MockClient(...))   // inyecta un cliente falso para tests
```

`: _client = client ?? http.Client()` es el **initializer list**: inicializa `_client` antes de que se ejecute el cuerpo del constructor.

---

### Método 1: `searchBreeds` — Buscar razas

```dart
Future<List<BreedModel>> searchBreeds(String query) async {
```

**`Future<List<BreedModel>>`** = "prometo que en el futuro devuelveré una lista de BreedModel".
**`async`** = esta función es asíncrona, puede usar `await` dentro.

```dart
  final cleanQuery = query.trim();
  if (cleanQuery.isEmpty) {
    return [];  // no hacer petición si el query está vacío
  }
```

Validación defensiva: si el usuario pasó texto vacío (o solo espacios), devuelve lista vacía inmediatamente sin hacer la petición HTTP.

```dart
  final url = Uri.parse(ApiConstants.searchBreedsUrl(cleanQuery));
  // Uri.parse convierte el string a un objeto Uri que http puede usar
  // url = Uri('https://api.thedogapi.com/v1/breeds/search?q=golden')
```

`Uri.parse()` convierte el string de URL a un objeto `Uri` de Dart, que el paquete `http` requiere para hacer peticiones.

```dart
  try {
    final response = await _client.get(
      url,
      headers: ApiConstants.headers,
    ).timeout(const Duration(seconds: 10));
```

- `await` → espera la respuesta sin bloquear la app
- `_client.get(url, headers: ...)` → petición HTTP GET con headers de autenticación
- `.timeout(Duration(seconds: 10))` → si no responde en 10 segundos, lanza `TimeoutException`

```dart
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
          .toList();
```

- `response.statusCode == 200` → HTTP 200 = éxito
- `json.decode(response.body)` → convierte el string JSON a un objeto Dart (`List<dynamic>` en este caso)
- `.map(...)` → convierte cada elemento del JSON a un `BreedModel`
- `.toList()` → materializa el iterable en una lista real

```dart
    } else if (response.statusCode == 429) {
      throw DogApiException(
        '¡Límite de peticiones excedido (429)! Por favor espera...',
        statusCode: 429,
      );
    } else {
      throw DogApiException(
        'Error al buscar razas (Código ${response.statusCode}). Por favor intente más tarde.',
        statusCode: response.statusCode,
      );
    }
```

**Códigos HTTP importantes:**

| Código | Significado |
|--------|-------------|
| 200 | OK — petición exitosa |
| 400 | Bad Request — parámetros inválidos |
| 401 | Unauthorized — API key inválida o faltante |
| 404 | Not Found — recurso no existe |
| 429 | Too Many Requests — excediste el límite de la API |
| 500 | Internal Server Error — fallo en el servidor de la API |

El código 429 se maneja especialmente porque TheDogAPI tiene límites de peticiones. Cuando lo excedes, hay que esperar antes de reintentar.

```dart
  } on DogApiException {
    rethrow;  // si ya es DogApiException, no envolver de nuevo
  } catch (e) {
    throw DogApiException(
      'Error de conexión a la API. Comprueba tu conexión a Internet...',
    );
  }
```

- `on DogApiException { rethrow; }` → si el error es una `DogApiException` (que lanzamos nosotros), la dejamos pasar tal cual
- `catch (e) { ... }` → cualquier otro error (timeout, no hay internet, DNS error) se convierte en `DogApiException` con mensaje amigable

---

### Método 2: `getImageDetails` — Obtener detalle de imagen

```dart
Future<DogImageModel?> getImageDetails(String imageId) async {
  if (imageId.isEmpty) return null;  // validación

  final url = Uri.parse(ApiConstants.imageDetailUrl(imageId));
  // url = 'https://api.thedogapi.com/v1/images/BJa4kxc4X'

  try {
    final response = await _client.get(
      url,
      headers: ApiConstants.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      // ↑ aquí es Map (objeto) no List (array), porque /images/{id} devuelve UN objeto
      return DogImageModel.fromJson(jsonMap);
    } else if (response.statusCode == 429) {
      throw DogApiException('¡Límite de peticiones excedido (429)!', statusCode: 429);
    }
    return null;  // para cualquier otro error no-200, devuelve null silenciosamente
  } catch (e) {
    return null;  // ← diferencia importante: aquí no re-lanza el error
    // Si falla obtener la imagen extra, no importa tanto — la pantalla
    // igual puede mostrar el breed con la imagen que ya tiene
  }
}
```

**Diferencia de manejo de errores entre los dos métodos:**

| | `searchBreeds` | `getImageDetails` |
|--|----------------|-------------------|
| Si falla | Lanza excepción (es crítico) | Devuelve `null` (es secundario) |
| Efecto en UI | FutureBuilder muestra `ErrorStateWidget` | La pantalla muestra la imagen que ya tenía |
| ¿Por qué? | Sin resultados, la pantalla 2 no puede funcionar | La pantalla 3 puede funcionar igual sin la imagen extra |

---

## El flujo completo de una petición

```
1. Usuario escribe "Golden" y presiona buscar
   BreedSearchScreen._onSearchSubmitted("Golden")

2. Se navega a SearchResultsScreen
   Navigator.push → SearchResultsScreen(initialQuery: "Golden")

3. SearchResultsScreen pide los datos
   _apiService.searchBreeds("Golden")  ← Future<List<BreedModel>>

4. DogApiService construye la URL
   ApiConstants.searchBreedsUrl("Golden")
   → "https://api.thedogapi.com/v1/breeds/search?q=Golden"

5. DogApiService hace la petición HTTP
   GET https://api.thedogapi.com/v1/breeds/search?q=Golden
   Headers: { Content-Type: application/json, x-api-key: "..." }

6. La API responde
   HTTP 200 OK
   Body: [{"id": 95, "name": "Golden Retriever", ...}, ...]

7. DogApiService parsea el JSON
   json.decode(response.body) → List<dynamic>
   .map(BreedModel.fromJson) → List<BreedModel>

8. El Future completa con los datos
   Future<List<BreedModel>> → [BreedModel(id:"95", name:"Golden"), ...]

9. FutureBuilder recibe los datos
   snapshot.connectionState == done
   snapshot.data = [BreedModel, BreedModel, ...]
   → Dibuja ListView con DogCard por cada raza
```

---

## ¿Qué pasa cuando algo falla?

```
Escenario A: Sin internet
  DogApiService.searchBreeds()
  → _client.get() lanza SocketException
  → catch(e) captura SocketException
  → throw DogApiException("Error de conexión...")
  → Future completa con error
  → FutureBuilder: snapshot.hasError == true
  → Dibuja ErrorStateWidget("Error de conexión...")
  → Usuario ve botón "Reintentar"

Escenario B: Timeout (10 segundos sin respuesta)
  → _client.get().timeout() lanza TimeoutException
  → catch(e) captura TimeoutException
  → throw DogApiException("Error de conexión...")
  → Mismo flujo que arriba

Escenario C: Error 429 (demasiadas peticiones)
  → response.statusCode == 429
  → throw DogApiException("¡Límite de peticiones!", statusCode: 429)
  → Future completa con error
  → FutureBuilder → ErrorStateWidget
  → ErrorStateWidget detecta "429" en el mensaje
  → Muestra ícono de reloj y color naranja (distinto al error normal)
```

---

## Conceptos HTTP que debes saber

### ¿Qué es una petición GET?

- `GET` = "dame información" (solo lectura, no modifica nada)
- La app hace GET a la API para **obtener** razas e imágenes
- Opuesto: `POST` = "envíame nueva información", `PUT` = "actualiza", `DELETE` = "borra"

### ¿Qué son los Headers?

Son metadatos que van junto a cada petición HTTP (como el sobre de una carta):

```
GET /v1/breeds/search?q=Golden HTTP/1.1
Host: api.thedogapi.com
Content-Type: application/json      ← tipo de contenido que enviamos
x-api-key: tu_clave_aqui            ← autenticación
```

### ¿Qué es el Body de la respuesta?

El contenido de la respuesta HTTP. En este caso es JSON (texto):
```json
[{"id": 95, "name": "Golden Retriever", ...}]
```

`response.body` en Dart es ese texto, y `json.decode()` lo convierte a objetos Dart.

---

## Buenas prácticas que implementa el servicio

1. **Validación de entrada** → `if (cleanQuery.isEmpty) return []`
2. **Timeout** → `.timeout(Duration(seconds: 10))` — no espera indefinidamente
3. **Manejo de status codes** → 200 éxito, 429 rate limit, otros errores
4. **Excepciones tipadas** → `DogApiException` con mensaje y statusCode
5. **Inyección de dependencias** → `{http.Client? client}` — testeable
6. **Degradación elegante** → `getImageDetails` devuelve null en vez de crashear

---

*Siguiente: `07_pantalla1_busqueda.md` — BreedSearchScreen en detalle 🔍*
