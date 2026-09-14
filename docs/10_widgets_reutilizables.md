# 10 — Widgets Reutilizables: DogCard, EmptyState, ErrorState 🧩

> Los widgets reutilizables son los **componentes** de la app. En lugar de escribir el mismo código de UI en varias pantallas, se encapsula en una clase que se puede usar en cualquier lugar. Aquí aprendes el patrón de composición de widgets en Flutter.

---

## ¿Por qué widgets reutilizables?

```
❌ Sin widgets reutilizables:
search_results_screen.dart → código de tarjeta (100 líneas)
other_screen.dart → el mismo código de tarjeta (100 líneas repetidas)

✅ Con widgets reutilizables:
dog_card.dart → código de tarjeta (100 líneas, una sola vez)
search_results_screen.dart → DogCard(breed: breed, onTap: ...)
other_screen.dart → DogCard(breed: otherBreed, onTap: ...)
```

La carpeta `presentation/widgets/` contiene componentes que **no son pantallas completas**, sino piezas que se usan dentro de pantallas.

---

## 📄 `dog_card.dart` — La tarjeta de raza

**Archivo:** [`lib/features/dog_search/presentation/widgets/dog_card.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/widgets/dog_card.dart)

### ¿Qué muestra?

```
┌────────────────────────────────────┐
│  ┌──────────────────────────────┐  │
│  │ 🖼️ IMAGEN DEL PERRO         │  │ ← 190px de alto, BoxFit.cover
│  │                    [Sporting]│  │ ← Badge del grupo de raza
│  └──────────────────────────────┘  │
│                                    │
│  Golden Retriever            →    │ ← Nombre + flecha derecha
│  📍 United Kingdom                 │ ← Origen
│  [Friendly] [Active] [Kind]       │ ← Primeros 3 tags de temperamento
└────────────────────────────────────┘
```

### La clase

```dart
class DogCard extends StatelessWidget {   // sin estado — solo muestra datos
  final BreedModel breed;   // los datos de la raza
  final VoidCallback onTap; // qué hacer al tocar la tarjeta

  const DogCard({
    super.key,
    required this.breed,   // obligatorio
    required this.onTap,   // obligatorio
  });
```

**`VoidCallback`** → es el tipo de una función que no recibe parámetros y no devuelve nada: `() → void`. Es el tipo correcto para callbacks de interacción.

**Separación de responsabilidades:** `DogCard` no sabe qué hacer cuando se toca. Solo invoca `onTap` y quien la usa decide qué pasa. En `SearchResultsScreen`, `onTap` navega a `DogDetailScreen`.

```dart
// Uso en search_results_screen.dart:
DogCard(
  breed: breed,
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => DogDetailScreen(breed: breed),
    ));
  },
)
```

---

### El método `build()`

```dart
@override
Widget build(BuildContext context) {
  final imageUrl = getImageUrl(breed.imageUrl);   // URL de imagen (con proxy CORS si web)
  final tags = breed.temperamentTags.take(3).toList(); // solo los primeros 3 tags
```

**`.take(3)`** → toma solo los primeros 3 elementos de la lista. Un Golden Retriever puede tener 6 temperamentos: `['Intelligent', 'Friendly', 'Reliable', 'Trustworthy', 'Kind', 'Confident']`. Mostrar los 6 en una tarjeta pequeña se vería mal; solo mostramos los primeros 3.

```dart
  return Card(
    clipBehavior: Clip.antiAlias,     // recorta los hijos a los bordes redondeados de la Card
    margin: const EdgeInsets.only(bottom: 16),  // espacio entre tarjetas
    child: InkWell(
      onTap: onTap,   // toda la tarjeta es tappable
```

**`Clip.antiAlias`** → necesario para que la imagen respete las esquinas redondeadas de la `Card`. Sin esto, la imagen se saldría de las esquinas.

**`InkWell`** → agrega el efecto ripple (onda) al tocar, que es el feedback visual estándar de Material Design.

---

### La imagen con Stack + badge

```dart
Stack(
  children: [
    // La imagen
    Container(
      height: 190,
      width: double.infinity,
      color: Colors.amber.shade50,  // fondo mientras carga
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;  // ya cargó
                return Center(
                  child: CircularProgressIndicator(
                    // progreso de carga (0.0 a 1.0 si se conoce el tamaño)
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();  // si falla, muestra placeholder
              },
            )
          : _buildImagePlaceholder(),  // si no hay URL, muestra placeholder
    ),
    
    // Badge del grupo de raza (solo si tiene grupo)
    if (breed.breedGroup != null && breed.breedGroup!.isNotEmpty)
      Positioned(
        top: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            breed.breedGroup!,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
  ],
),
```

---

### El placeholder cuando no hay imagen

```dart
Widget _buildImagePlaceholder() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.pets_rounded,
        size: 48,
        color: AppTheme.primaryColor.withValues(alpha: 0.4),  // naranja transparente
      ),
      const SizedBox(height: 8),
      const Text(
        'Imagen no disponible',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
    ],
  );
}
```

Método privado (con prefijo `_` implícito al ser dentro de clase) que devuelve un widget de placeholder. Reutilizado en dos lugares: cuando no hay URL y cuando la URL falla.

---

### La sección de información

```dart
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Nombre + flecha derecha
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              breed.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,  // "Golden Retriev..." si es muy largo
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryColor),
        ],
      ),
      
      // Origen (si existe)
      if (breed.origin != null && breed.origin!.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(breed.origin!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ],
      
      // Tags de temperamento (si hay)
      if (tags.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor)),
            );
          }).toList(),
        ),
      ],
    ],
  ),
),
```

---

## 📄 `empty_state_widget.dart` — Sin resultados

**Archivo:** [`lib/features/dog_search/presentation/widgets/empty_state_widget.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/widgets/empty_state_widget.dart)

```
┌──────────────────────────┐
│                          │
│  ┌──┐                   │
│  │ 🔍 │  (círculo ámbar)  │ ← ícono en contenedor circular
│  └──┘                   │
│                          │
│  No se encontraron razas │ ← título
│                          │
│  No hallamos coincidencias│ ← descripción con el query
│  para "xyz"...           │
│                          │
│  [↺ Intentar nueva búsqueda] │ ← botón (opcional)
└──────────────────────────┘
```

### La clase

```dart
class EmptyStateWidget extends StatelessWidget {
  final String query;          // la búsqueda que no dio resultados
  final VoidCallback? onReset; // callback opcional para el botón
```

`onReset` es `VoidCallback?` (nullable) — el botón es **opcional**. Si no se pasa `onReset`, el botón no se muestra.

### El botón condicional

```dart
if (onReset != null) ...[
  const SizedBox(height: 24),
  ElevatedButton.icon(
    onPressed: onReset,                      // llama al callback
    icon: const Icon(Icons.refresh_rounded),
    label: const Text('Intentar nueva búsqueda'),
  ),
],
```

`if (onReset != null)` → si se pasó un callback, muestra el botón.

### Cómo se usa

```dart
// En search_results_screen.dart
EmptyStateWidget(
  query: _currentQuery,  // "xyz" — para mostrar en el mensaje
  onReset: () {
    Navigator.pop(context);  // vuelve a la pantalla de búsqueda
  },
)
```

---

## 📄 `error_state_widget.dart` — Estado de error

**Archivo:** [`lib/features/dog_search/presentation/widgets/error_state_widget.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/widgets/error_state_widget.dart)

```
Estado normal de error:         Estado rate limit (429):
┌──────────────────────┐        ┌──────────────────────┐
│   ┌──┐              │        │   ┌──┐              │
│   │ 📶 │ (rojo)      │        │   │ ⏱ │ (naranja)    │
│   └──┘              │        │   └──┘              │
│                      │        │                      │
│ Ocurrió un           │        │ ¡Límite de           │
│ inconveniente        │        │ peticiones!          │
│                      │        │                      │
│ Mensaje del error    │        │ Mensaje del error    │
│                      │        │                      │
│   [↺ Reintentar]     │        │   [↺ Reintentar]     │
│   (rojo/naranja)     │        │   (naranja)          │
└──────────────────────┘        └──────────────────────┘
```

### La clase

```dart
class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;   // el mensaje de error
  final VoidCallback onRetry;  // callback para reintentar (obligatorio)
```

A diferencia de `EmptyStateWidget`, `onRetry` es **requerido** (no nullable) porque siempre debe haber una forma de reintentar.

### Detección inteligente del tipo de error

```dart
@override
Widget build(BuildContext context) {
  final isRateLimit = errorMessage.contains('429');
  // true si el mensaje contiene "429" → es un error de rate limit
```

Esta línea detecta si el error es el código 429 (Too Many Requests) buscando "429" en el mensaje. Si es así, cambia el ícono y el color para dar feedback visual diferente.

```dart
  // Ícono adaptativo
  Icon(
    isRateLimit ? Icons.timer_rounded : Icons.wifi_off_rounded,
    color: isRateLimit ? Colors.orange : Colors.redAccent,
  )
  
  // Título adaptativo
  Text(isRateLimit ? '¡Límite de peticiones!' : 'Ocurrió un inconveniente')
  
  // Color del botón adaptativo
  ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: isRateLimit ? Colors.orange : AppTheme.primaryColor,
    ),
  )
```

Este patrón es **condicional basado en datos** — el mismo widget se ve diferente según el tipo de error.

### Cómo se usa

```dart
// En search_results_screen.dart
if (snapshot.hasError) {
  return ErrorStateWidget(
    errorMessage: snapshot.error.toString(),  // el mensaje que lanzó DogApiException
    onRetry: _fetchResults,                   // botón reintentar → vuelve a buscar
  );
}
```

---

## Patrón de diseño: Callback

Un patrón muy común en Flutter es pasar **funciones como parámetros** para desacoplar los widgets de su lógica:

```dart
// El widget no sabe QUÉ hacer, solo CUÁNDO llamar al callback
class DogCard extends StatelessWidget {
  final VoidCallback onTap;   // alguien de afuera define qué pasa al tocar
  
  Widget build(context) {
    return InkWell(
      onTap: onTap,  // invoca el callback cuando el usuario toca
      child: ...
    );
  }
}

// Quien usa DogCard define el comportamiento:
DogCard(
  breed: breed,
  onTap: () => Navigator.push(...)  // aquí sí sabe qué hacer
)
```

**Ventaja:** `DogCard` se puede reutilizar en diferentes contextos con diferentes comportamientos al tocar.

---

## Tabla comparativa de los 3 widgets

| | `DogCard` | `EmptyStateWidget` | `ErrorStateWidget` |
|--|-----------|-------------------|-------------------|
| Tipo | StatelessWidget | StatelessWidget | StatelessWidget |
| ¿Tiene estado? | No | No | No |
| Parámetro principal | `BreedModel breed` | `String query` | `String errorMessage` |
| Callback | `VoidCallback onTap` (req) | `VoidCallback? onReset` (opt) | `VoidCallback onRetry` (req) |
| ¿Cuándo se usa? | En lista de resultados | Cuando API devuelve `[]` | Cuando API lanza error |
| ¿Cambia según datos? | Sí (imagen, tags) | Sí (muestra el query) | Sí (ícono según 429) |

---

## Resumen final — Conceptos aprendidos en estos widgets

| Concepto | Ejemplo |
|----------|---------|
| `StatelessWidget` | Los 3 widgets son sin estado |
| `VoidCallback` | Tipo para funciones `() → void` |
| Callback opcional `?` | `VoidCallback? onReset` — puede ser null |
| `Clip.antiAlias` | Imagen respeta bordes redondeados |
| `InkWell` | Efecto ripple al tocar |
| `.take(3)` | Solo los primeros 3 elementos de la lista |
| Placeholder | Widget alternativo cuando falla la imagen |
| `errorMessage.contains('429')` | Detección de tipo de error |
| Condicional en UI | `isRateLimit ? naranja : rojo` |
| `if (...) ...[Widget]` | Mostrar widgets condicionalmente |
| `TextOverflow.ellipsis` | Texto largo → "..." |

---

## 🎉 ¡Felicidades! Ya conoces TODO el proyecto

Repasando lo que aprendiste:

1. **Dart** → tipos, funciones, clases, async/await, null safety
2. **Flutter** → widgets, estado, StatelessWidget, StatefulWidget, setState
3. **Arquitectura** → Feature-First, separación Data/Presentation, core/
4. **Core** → ApiConstants, AppTheme, ImageHelper (CORS proxy)
5. **Modelos** → BreedModel, DogImageModel, factory fromJson
6. **Servicio API** → HTTP GET, json.decode, manejo de errores, DogApiException
7. **Pantalla 1** → TextField, Navigator.push, ActionChip, debounce
8. **Pantalla 2** → FutureBuilder, ListView.builder, 4 estados de carga
9. **Pantalla 3** → SliverAppBar, CustomScrollView, InteractiveViewer, mounted
10. **Widgets** → DogCard, EmptyStateWidget, ErrorStateWidget, callbacks

---

*Empieza desde `00_indice_y_mapa_del_proyecto.md` si quieres repasar. ¡Mucho éxito! 🚀🐾*
