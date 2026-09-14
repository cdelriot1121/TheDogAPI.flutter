# 05 — Modelos de Datos: BreedModel y DogImageModel 📦

> Los **modelos** son las clases que representan la información de la app. Son como "moldes" que definen la forma de los datos que vienen de la API. En este archivo entenderás cómo se toma el JSON crudo de la API y se convierte en objetos Dart útiles.

---

## ¿Qué es un modelo de datos?

La API devuelve texto JSON. Un **modelo** convierte ese texto en un objeto Dart con propiedades tipadas que puedes usar fácilmente.

```
API responde JSON:                    BreedModel (objeto Dart):
{                                     BreedModel(
  "id": "95",           →               id: "95",
  "name": "Golden",     →               name: "Golden",
  "life_span": "10-12"  →               lifeSpan: "10-12",
}                                     )
```

---

## 📄 `breed_model.dart` — La raza de perro

**Archivo:** [`lib/features/dog_search/data/models/breed_model.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/data/models/breed_model.dart)

### La respuesta real de la API

Cuando llamas a `/breeds/search?q=Golden`, la API devuelve algo como esto:

```json
[
  {
    "id": 95,
    "name": "Golden Retriever",
    "life_span": "10 - 12 years",
    "temperament": "Intelligent, Friendly, Reliable, Trustworthy, Kind, Confident",
    "origin": "United Kingdom",
    "country_code": "GB",
    "description": "The Golden Retriever is a large-sized breed of dog...",
    "bred_for": "Retrieving fowl, upland game",
    "breed_group": "Sporting",
    "history": "The breed was developed in Scotland...",
    "reference_image_id": "BJa4kxc4X",
    "weight": {
      "imperial": "55 - 75",
      "metric": "25 - 34"
    },
    "height": {
      "imperial": "21.5 - 24",
      "metric": "55 - 61"
    },
    "image": {
      "id": "BJa4kxc4X",
      "width": 1023,
      "height": 680,
      "url": "https://cdn2.thedogapi.com/images/BJa4kxc4X.jpg"
    }
  }
]
```

### Las propiedades del modelo

```dart
class BreedModel {
  final String id;              // "95"
  final String name;            // "Golden Retriever"
  final String? lifeSpan;       // "10 - 12 years" (puede ser null)
  final String? temperament;    // "Intelligent, Friendly, ..."
  final String? origin;         // "United Kingdom"
  final String? countryCode;    // "GB"
  final String? description;    // texto largo
  final String? bredFor;        // "Retrieving fowl, upland game"
  final String? perfectFor;     // no siempre viene (nullable)
  final String? breedGroup;     // "Sporting"
  final String? history;        // texto largo de historia
  final String? referenceImageId; // "BJa4kxc4X"
  final String? metricWeight;   // "25 - 34" (parseado del objeto weight)
  final String? imperialWeight; // "55 - 75"
  final String? metricHeight;   // "55 - 61"
  final String? imperialHeight; // "21.5 - 24"
  final String? directImageUrl; // URL directa si viene en el objeto image
```

Casi todos son `String?` (nullable) porque la API no garantiza que todos los campos existan en todas las razas.

---

### El constructor

```dart
  BreedModel({
    required this.id,     // obligatorio, siempre existe
    required this.name,   // obligatorio, siempre existe
    this.lifeSpan,        // opcional (se asigna null por defecto si no se pasa)
    this.temperament,
    this.origin,
    // ... demás campos opcionales
  });
```

Los campos con `required` DEBEN pasarse al crear un objeto. Los sin `required` son opcionales.

---

### El factory constructor `fromJson` — La magia del parsing

```dart
  factory BreedModel.fromJson(Map<String, dynamic> json) {
```

`Map<String, dynamic>` = el JSON como un diccionario Dart. Las claves son `String`, los valores son `dynamic` (pueden ser cualquier tipo).

```dart
    // Parse weight map safely (parseado seguro del mapa de peso)
    String? mWeight;
    String? iWeight;
    if (json['weight'] is Map) {        // ¿es un objeto anidado? {metric: "25"}
      mWeight = json['weight']['metric']?.toString();   // accede a peso métrico
      iWeight = json['weight']['imperial']?.toString(); // accede a peso imperial
    }
```

**¿Por qué `?.toString()`?**

- `json['weight']['metric']` podría ser null si no existe
- `?.` (safe call) → si es null, devuelve null en vez de error
- `.toString()` → convierte el valor a String (puede ser un número en el JSON)

```dart
    // Parse nested image safely
    String? imageUrl;
    if (json['image'] is Map && json['image']['url'] != null) {
      imageUrl = json['image']['url'].toString();
    }
```

Aquí extrae la URL directa de la imagen del objeto anidado `image`.

```dart
    return BreedModel(
      id: json['id']?.toString() ?? '',
      // ↑ json['id'] puede ser int o string, .toString() lo normaliza
      // ?? '' → si es null, usa string vacío
      
      name: json['name']?.toString() ?? 'Raza Desconocida',
      // ↑ Si no hay nombre, usa valor por defecto legible
      
      lifeSpan: json['life_span']?.toString(),
      // ↑ Nota: en la API es "life_span" (snake_case)
      // En Dart usamos "lifeSpan" (camelCase) — convención del lenguaje
      
      countryCode: (json['country_code'] ?? json['country_codes'])?.toString(),
      // ↑ La API a veces usa 'country_code' y otras 'country_codes'
      // Este código maneja ambas posibilidades
    );
  }
```

---

### Los getters calculados

```dart
  /// Returns the best available image URL for this breed
  String? get imageUrl {
    if (directImageUrl != null && directImageUrl!.isNotEmpty) {
      return directImageUrl;  // preferir URL directa del objeto image
    }
    if (referenceImageId != null && referenceImageId!.isNotEmpty) {
      return ApiConstants.imageUrlFromId(referenceImageId!);
      // → 'https://cdn2.thedogapi.com/images/BJa4kxc4X.jpg'
    }
    return null;  // no hay imagen disponible
  }
```

Este getter implementa la lógica de prioridad de imágenes:
1. Si la raza viene con URL de imagen directa → úsala
2. Si tiene `referenceImageId` → construye la URL del CDN
3. Si no tiene nada → devuelve null

```dart
  /// Parsed temperament tags
  List<String> get temperamentTags {
    if (temperament == null || temperament!.isEmpty || temperament == 'unknown') {
      return [];  // sin temperamento → lista vacía
    }
    return temperament!
        .split(',')              // "Friendly, Active, Kind" → ['Friendly', ' Active', ' Kind']
        .map((e) => e.trim())   // quita espacios → ['Friendly', 'Active', 'Kind']
        .where((e) => e.isNotEmpty) // filtra vacíos
        .toList();              // convierte a List<String>
  }
```

Convierte el string `"Intelligent, Friendly, Kind"` en una lista `['Intelligent', 'Friendly', 'Kind']` que la UI puede mapear a chips visuales.

---

## 📄 `dog_image_model.dart` — La imagen de un perro

**Archivo:** [`lib/features/dog_search/data/models/dog_image_model.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/data/models/dog_image_model.dart)

### ¿Para qué existe este modelo si ya tenemos `BreedModel`?

Cuando llamas al endpoint `GET /images/{id}`, la API devuelve **más información** sobre la imagen, incluyendo sus dimensiones reales y, a veces, datos de razas enriquecidos:

```json
{
  "id": "BJa4kxc4X",
  "url": "https://cdn2.thedogapi.com/images/BJa4kxc4X.jpg",
  "width": 1023,
  "height": 680,
  "breeds": [
    { "id": 95, "name": "Golden Retriever", ... }
  ]
}
```

`DogDetailScreen` llama a este endpoint para obtener la URL real de la imagen (que puede ser más grande o en mejor calidad que la que viene en la búsqueda inicial).

### El modelo

```dart
class DogImageModel {
  final String id;           // "BJa4kxc4X"
  final String url;          // URL de la imagen
  final int? width;          // ancho en píxeles (puede ser null)
  final int? height;         // alto en píxeles (puede ser null)
  final List<BreedModel> breeds; // lista de razas de esta imagen
```

### El factory constructor

```dart
  factory DogImageModel.fromJson(Map<String, dynamic> json) {
    List<BreedModel> breedsList = [];
    if (json['breeds'] is List) {
      breedsList = (json['breeds'] as List)
          .map((b) => BreedModel.fromJson(b as Map<String, dynamic>))
          .toList();
    }
    // ↑ Si 'breeds' es una lista JSON, convierte cada elemento en BreedModel
    
    return DogImageModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      width: json['width'] is int ? json['width'] : null,
      // ↑ Solo lo asigna si es entero (type check con 'is')
      height: json['height'] is int ? json['height'] : null,
      breeds: breedsList,
    );
  }
```

**`json['width'] is int`** → comprueba el tipo antes de asignar. Si la API devuelve `null` o un string en ese campo, no crashea.

---

## Relación entre los dos modelos

```
DogImageModel
├── id: "BJa4kxc4X"
├── url: "https://cdn2.thedogapi.com/..."
├── width: 1023
├── height: 680
└── breeds: [
      BreedModel(id: "95", name: "Golden Retriever", ...)  ← usa el mismo modelo
    ]
```

`DogImageModel` contiene una lista de `BreedModel`. Es un ejemplo de **composición**: un modelo usa otro modelo como parte de su estructura.

---

## Cómo se usan los modelos en la UI

```dart
// En search_results_screen.dart — lista de razas
final breeds = snapshot.data ?? [];  // List<BreedModel>
breeds.length                         // cuántas razas hay
breeds[0].name                        // "Golden Retriever"
breeds[0].imageUrl                    // URL de la imagen

// En dog_card.dart — mostrar una raza
Text(breed.name)
Image.network(getImageUrl(breed.imageUrl))
breed.temperamentTags.take(3)  // primeros 3 tags de temperamento

// En dog_detail_screen.dart — mostrar detalle
widget.breed.metricWeight      // "25 - 34"
widget.breed.lifeSpan          // "10 - 12 years"
widget.breed.temperamentTags   // ['Intelligent', 'Friendly', ...]
```

---

## Patrones importantes del parsing JSON

### Patrón 1: Acceso seguro con `?.toString()`
```dart
json['nombre_campo']?.toString()
// Si el campo es null → devuelve null
// Si el campo existe → lo convierte a String
```

### Patrón 2: Valor por defecto con `??`
```dart
json['id']?.toString() ?? ''
// Si el campo es null → usa ''
json['name']?.toString() ?? 'Desconocido'
// Si el campo es null → usa 'Desconocido'
```

### Patrón 3: Comprobación de tipo con `is`
```dart
if (json['weight'] is Map) { ... }    // ¿es un objeto? {}
if (json['breeds'] is List) { ... }   // ¿es un array? []
if (json['width'] is int) { ... }     // ¿es un número entero?
```

### Patrón 4: Cast con `as`
```dart
(json['breeds'] as List)
    .map((b) => BreedModel.fromJson(b as Map<String, dynamic>))
// Convierte el tipo dynamic a List, luego cada elemento a Map
```

---

## Tabla comparativa de los dos modelos

| Característica | `BreedModel` | `DogImageModel` |
|----------------|-------------|-----------------|
| Endpoint | `/breeds/search` | `/images/{id}` |
| Datos principales | Info de la raza (nombre, origen, temperamento) | Info de la imagen (URL, dimensiones) |
| Imagen | `imageUrl` getter calculado | `url` campo directo |
| ¿Contiene el otro? | No | Sí: `breeds: List<BreedModel>` |
| Cuándo se crea | Al buscar razas (pantalla 2) | Al cargar detalle (pantalla 3) |

---

*Siguiente: `06_servicio_api_http.md` — cómo la app habla con TheDogAPI 🌐*
