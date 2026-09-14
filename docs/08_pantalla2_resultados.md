# 08 — Pantalla 2: Resultados (SearchResultsScreen) 📋

> La segunda pantalla muestra la lista de razas que coinciden con la búsqueda. Aquí aprendes el patrón más importante de Flutter para datos asíncronos: **FutureBuilder**, además de `initState`, `late`, y los tres estados posibles de una pantalla con datos remotos.

---

## ¿Qué muestra esta pantalla?

```
┌──────────────────────────────────┐
│ ← Pantalla 2: Resultados         │  ← AppBar con botón atrás
├──────────────────────────────────┤
│ [🔍 Buscar otra raza...] [Buscar]│  ← Barra de búsqueda refinable
├──────────────────────────────────┤
│                                  │
│  Estado 1: Cargando              │  ← CircularProgressIndicator + texto
│  ◌ Consultando TheDogAPI...      │
│                                  │
│  Estado 2: Error                 │  ← ErrorStateWidget
│  ⚠️ Error de conexión            │
│       [Reintentar]               │
│                                  │
│  Estado 3: Sin resultados        │  ← EmptyStateWidget
│  🔍 No se encontraron razas      │
│    [Nueva búsqueda]              │
│                                  │
│  Estado 4: Con resultados        │  ← ListView con DogCard
│  Se encontraron 3 razas          │
│  ┌──────────────────────────┐    │
│  │ 🖼️ [imagen]              │    │
│  │ Golden Retriever         │    │
│  │ 📍 United Kingdom        │    │
│  │ [Friendly][Active][Kind] │    │
│  └──────────────────────────┘    │
│  [otra DogCard...]               │
└──────────────────────────────────┘
```

---

## 📄 Análisis del código

**Archivo:** [`lib/features/dog_search/presentation/screens/search_results_screen.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/screens/search_results_screen.dart)

### La clase StatefulWidget con parámetro

```dart
class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;   // dato que recibe desde BreedSearchScreen

  const SearchResultsScreen({
    super.key,
    required this.initialQuery,  // obligatorio
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}
```

**Pasar datos entre pantallas:**

```dart
// En BreedSearchScreen (pantalla 1):
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchResultsScreen(initialQuery: "Golden"),
    // ↑ se pasa el dato al constructor
  ),
);

// En SearchResultsScreen (pantalla 2):
class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;  // recibe "Golden"
  // ...
}
```

---

### El estado con `late`

```dart
class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final DogApiService _apiService = DogApiService();  // servicio de API
  late String _currentQuery;                           // query actual
  late Future<List<BreedModel>> _breedsFuture;         // el Future de resultados
  final TextEditingController _searchController = TextEditingController();
```

**`late`** → marca una variable que se inicializará **más tarde** (no en la declaración). Le dices a Dart: *"confía en mí, la inicializaré antes de usarla"*. Si usas una variable `late` antes de inicializarla, obtienes `LateInitializationError`.

Se usa `late` para `_currentQuery` y `_breedsFuture` porque se inicializan en `initState()`, no en la declaración.

---

### `initState()` — Inicialización al entrar a la pantalla

```dart
@override
void initState() {
  super.initState();                          // SIEMPRE llamar primero
  _currentQuery = widget.initialQuery;        // toma el query del widget padre
  _searchController.text = _currentQuery;     // pre-llena el campo de búsqueda
  _fetchResults();                            // dispara la primera búsqueda
}
```

**`widget.initialQuery`** → accede a las propiedades del `StatefulWidget` desde el `State` usando `widget.`. Así `_SearchResultsScreenState` accede a `SearchResultsScreen.initialQuery`.

`initState()` se llama **una sola vez** cuando la pantalla aparece por primera vez. Es el lugar ideal para:
- Inicializar variables
- Cargar datos iniciales de la API

---

### `_fetchResults()` — Actualizar los resultados

```dart
void _fetchResults() {
  setState(() {
    _breedsFuture = _apiService.searchBreeds(_currentQuery);
  });
}
```

**¿Por qué `setState` aquí?**

`_breedsFuture` es el Future que `FutureBuilder` observa. Cuando cambiamos `_breedsFuture` dentro de `setState`, le decimos a `FutureBuilder` que empiece a observar el **nuevo** Future. Esto hace que FutureBuilder vuelva al estado "cargando" mientras espera los nuevos resultados.

```
_fetchResults() llama → setState({ _breedsFuture = nuevoFuture })
→ FutureBuilder recibe nuevo future
→ FutureBuilder: ConnectionState.waiting → muestra spinner
→ Future completa → FutureBuilder: snapshot.hasData → muestra lista
```

---

### `_onNewSearch()` — El usuario busca algo diferente

```dart
void _onNewSearch(String query) {
  final clean = query.trim();
  if (clean.isEmpty) return;
  setState(() {
    _currentQuery = clean;  // actualiza el query actual
  });
  _fetchResults();           // dispara nueva búsqueda
}
```

Nótese que llama a `setState` para actualizar `_currentQuery` y luego llama a `_fetchResults` que tiene su propio `setState`. Dos llamadas a `setState` sucesivas, pero Flutter las agrupa eficientemente.

---

### El `build()` completo

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Pantalla 2: Resultados'),
      // ↑ El botón "←" atrás aparece AUTOMÁTICAMENTE porque hay una pantalla anterior
    ),
    body: SafeArea(
      child: Column(
        children: [
          // 1. Barra de búsqueda
          _buildSearchBar(),
          
          // 2. Área de contenido (ocupa todo el espacio restante)
          Expanded(
            child: FutureBuilder<List<BreedModel>>(
              future: _breedsFuture,
              builder: _buildBody,
            ),
          ),
        ],
      ),
    ),
  );
}
```

`Expanded` en el `FutureBuilder` es crucial: le dice que ocupe todo el espacio vertical disponible después de la barra de búsqueda.

---

### El FutureBuilder — El corazón de la pantalla

```dart
FutureBuilder<List<BreedModel>>(
  future: _breedsFuture,
  builder: (context, snapshot) {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ESTADO 1: Cargando (el Future todavía está en proceso)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Consultando TheDogAPI para "$_currentQuery"...',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ESTADO 2: Error (la petición falló)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (snapshot.hasError) {
      return ErrorStateWidget(
        errorMessage: snapshot.error.toString(),
        onRetry: _fetchResults,  // botón reintentar llama a _fetchResults
      );
    }
    
    // A partir de aquí, el Future completó exitosamente
    final breeds = snapshot.data ?? [];  // lista de razas (o vacía)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ESTADO 3: Sin resultados (la API respondió pero no encontró nada)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (breeds.isEmpty) {
      return EmptyStateWidget(
        query: _currentQuery,
        onReset: () {
          Navigator.pop(context);  // volver a la pantalla de búsqueda
        },
      );
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ESTADO 4: Con resultados ¡éxito!
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de resultados
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Se encontraron ', style: TextStyle(color: AppTheme.textSecondary)),
              Text('${breeds.length} razas',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              Text(' para "$_currentQuery"', style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        
        // Lista de tarjetas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: breeds.length,
            itemBuilder: (context, index) {
              final breed = breeds[index];
              return DogCard(
                breed: breed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DogDetailScreen(breed: breed),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  },
)
```

---

### Los 4 estados del FutureBuilder

```
Future<List<BreedModel>>
        │
        ├─── ConnectionState.waiting
        │         └─→ CircularProgressIndicator + texto de carga
        │
        ├─── snapshot.hasError == true
        │         └─→ ErrorStateWidget(mensaje, onRetry)
        │
        ├─── snapshot.data == [] (lista vacía)
        │         └─→ EmptyStateWidget(query, onReset)
        │
        └─── snapshot.data tiene elementos
                  └─→ Lista de DogCard + contador de resultados
```

---

### La barra de búsqueda superior

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  color: Colors.amber.shade50.withValues(alpha: 0.4),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _searchController,
          onSubmitted: _onNewSearch,           // Enter → nueva búsqueda
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,                     // más compacta
            hintText: 'Buscar otra raza...',
            prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _onNewSearch(_searchController.text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: const Icon(Icons.search, size: 20),
      ),
    ],
  ),
),
```

Esta barra permite al usuario **refinar la búsqueda sin volver a la pantalla anterior**. Al buscar algo nuevo desde aquí, `_fetchResults()` llama a la API con el nuevo query y FutureBuilder redibuja los resultados.

---

### El flujo completo de navegación desde esta pantalla

```
SearchResultsScreen
    │
    │  Usuario toca una DogCard
    ↓
Navigator.push(DogDetailScreen(breed: breed))
    │
    │  La pantalla de detalle se abre
    ↓
DogDetailScreen está encima en el stack:
Stack: [BreedSearchScreen, SearchResultsScreen, DogDetailScreen]
    │
    │  Usuario presiona ← atrás
    ↓
Navigator.pop() → DogDetailScreen se cierra
Stack: [BreedSearchScreen, SearchResultsScreen]
    │
    │  Usuario presiona ← atrás de nuevo
    ↓
Navigator.pop() → SearchResultsScreen se cierra
Stack: [BreedSearchScreen]
```

---

## Conceptos clave de esta pantalla

| Concepto | Uso |
|----------|-----|
| `final String initialQuery` en StatefulWidget | Recibe datos de la pantalla anterior |
| `widget.initialQuery` en State | Accede a las propiedades del widget desde el state |
| `late` | Variables que se inicializan en `initState` |
| `initState()` | Carga inicial de datos al entrar a la pantalla |
| `FutureBuilder` | Maneja los 4 estados: loading, error, empty, success |
| `snapshot.connectionState` | Estado actual del Future |
| `snapshot.hasError` | Si el Future terminó con error |
| `snapshot.data` | Los datos del Future cuando completa |
| `ListView.builder` | Lista eficiente de DogCard |
| `DogCard(onTap: ...)` | Callback para navegar al detalle |
| Botón atrás automático | AppBar lo genera porque hay pantalla anterior |

---

*Siguiente: `09_pantalla3_detalle.md` — DogDetailScreen con SliverAppBar 🐕*
