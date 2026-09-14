# 07 — Pantalla 1: Búsqueda (BreedSearchScreen) 🔍

> La primera pantalla que el usuario ve. Es la página de inicio de la app. Aprende aquí: **StatefulWidget**, **TextEditingController**, **debounce con Timer**, **Navigator.push**, **Wrap con ActionChip**, y cómo construir un layout completo desde cero.

---

## ¿Qué muestra esta pantalla?

```
┌────────────────────────────────┐
│  🐾 TheDogAPI                  │ ← Header con ícono y título
│  Explorador de Razas           │
│                                │
│  ┌──────────────────────────┐  │
│  │ 🐶 Pantalla 1: Búsqueda  │  │ ← Banner hero naranja con degradado
│  │ Descubre todo sobre tu   │  │
│  │ canino favorito...       │  │
│  └──────────────────────────┘  │
│                                │
│  Ingresa una raza              │
│  [🔍 Ej. Terrier, Golden...] → │ ← TextField + botón buscar
│                                │
│  Búsquedas populares           │
│  [Terrier] [Golden] [Bulldog]  │ ← ActionChips
│  [Poodle] [Husky] [German]     │
│                                │
│  ℹ️ API REST: Consumiendo...   │ ← Nota informativa
└────────────────────────────────┘
```

---

## 📄 Análisis del código

**Archivo:** [`lib/features/dog_search/presentation/screens/breed_search_screen.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/screens/breed_search_screen.dart)

### Declaración del StatefulWidget

```dart
class BreedSearchScreen extends StatefulWidget {
  const BreedSearchScreen({super.key});

  @override
  State<BreedSearchScreen> createState() => _BreedSearchScreenState();
}
```

- `StatefulWidget` porque tiene un `TextEditingController` y un `Timer` que necesitan ser manejados
- `{super.key}` → pasa la key al constructor padre (buena práctica para Flutter)
- `createState()` → crea el objeto de estado `_BreedSearchScreenState`
- El prefijo `_` en `_BreedSearchScreenState` indica que es **privado** al archivo

---

### El estado interno

```dart
class _BreedSearchScreenState extends State<BreedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _quickSearches = [
    'Terrier', 'Golden', 'Bulldog', 'Poodle',
    'Husky', 'German', 'Beagle', 'Spaniel',
  ];
```

**`TextEditingController`:**
- Permite leer y escribir el texto de un `TextField` desde el código
- `_searchController.text` → texto actual
- `_searchController.clear()` → limpia el campo
- `_searchController.text = 'algo'` → escribe texto desde el código

**`Timer?`:**
- Un timer cancelable para implementar "debounce" (ver abajo)
- Es `Timer?` (nullable) porque inicialmente no existe ningún timer

**`_quickSearches`:**
- Lista de strings que se muestran como chips
- `final` porque la lista en sí no cambia (los chips son siempre los mismos)

---

### `dispose()` — Limpieza de recursos

```dart
@override
void dispose() {
  _debounceTimer?.cancel();      // cancela el timer si existe
  _searchController.dispose();   // libera la memoria del controller
  super.dispose();               // llama al dispose del padre (siempre al final)
}
```

`dispose()` se ejecuta cuando la pantalla se destruye (el usuario la cierra). Es **crucial** llamar `dispose()` en los controllers y timers para evitar **memory leaks** (pérdidas de memoria).

`_debounceTimer?.cancel()` → el `?.` significa: "si el timer existe, cancélalo; si es null, no hagas nada".

---

### `_onSearchSubmitted` — Navegar a resultados

```dart
void _onSearchSubmitted(String query) {
  final cleanQuery = query.trim();  // quita espacios al inicio y final
  if (cleanQuery.isEmpty) return;   // no navegar si está vacío

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(initialQuery: cleanQuery),
    ),
  );
}
```

**`Navigator.push`** agrega una nueva pantalla al stack de navegación:
```
Stack antes: [BreedSearchScreen]
Stack después: [BreedSearchScreen, SearchResultsScreen]
```

**`MaterialPageRoute`** define la transición animada entre pantallas (slide desde la derecha en Android, slide hacia arriba en iOS).

**`builder: (context) => ...`** es una función que crea la pantalla nueva. Se pasa `SearchResultsScreen` con el query del usuario.

---

### `_onQueryChanged` — Debounce (técnica avanzada)

```dart
void _onQueryChanged(String query) {
  if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 600), () {
    // Debounce logic if needed
  });
}
```

**¿Qué es debounce?**

El debounce evita que se disparen demasiadas acciones mientras el usuario escribe. Sin debounce, si el usuario escribe "Golden" (6 teclas), se harían 6 peticiones a la API. Con debounce, solo se hace UNA petición 600ms después de que deja de escribir.

```
Sin debounce:
Usuario escribe: G → o → l → d → e → n
Peticiones:      G   Go  Gol Gold Golde Golden  ← 6 peticiones

Con debounce (600ms):
Usuario escribe: G → o → l → d → e → n [pausa 600ms]
Peticiones:      (cancelada)(cancelada)...(cancelada)  Golden  ← 1 petición
```

En este proyecto el debounce está preparado pero la lógica está vacía (la búsqueda solo se dispara al presionar Enter/botón). Podrías completarlo así:

```dart
_debounceTimer = Timer(const Duration(milliseconds: 600), () {
  if (query.trim().isNotEmpty) {
    _onSearchSubmitted(query);  // buscar automáticamente
  }
});
```

---

### El método `build` — La UI completa

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
```

**`SingleChildScrollView`** → hace que el contenido sea scrolleable si no cabe en la pantalla. Importante para pantallas de formulario donde el teclado puede ocultar contenido.

**`EdgeInsets.symmetric(horizontal: 24, vertical: 20)`** → padding de 24px a los lados y 20px arriba/abajo.

---

### El Header — Ícono + Título

```dart
Row(
  children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),  // naranja transparente
        borderRadius: BorderRadius.circular(14),              // esquinas redondeadas
      ),
      child: const Icon(
        Icons.pets_rounded,
        color: AppTheme.primaryColor,
        size: 28,
      ),
    ),
    const SizedBox(width: 14),  // espacio entre ícono y texto
    const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TheDogAPI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        Text('Explorador de Razas', style: TextStyle(fontSize: 13)),
      ],
    ),
  ],
),
```

**`FontWeight.w900`** → el peso más grueso (ultra bold). La escala de pesos: w100 (delgado) a w900 (ultra grueso).

---

### El Banner Hero — Degradado naranja

```dart
Container(
  width: double.infinity,  // ocupa todo el ancho disponible
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF6F00), Color(0xFFFF9E80)],  // naranja a salmón
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),  // sombra 8px hacia abajo
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Badge "Pantalla 1"
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),  // blanco semi-transparente
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('🐶 Pantalla 1: Búsqueda', style: TextStyle(color: Colors.white)),
      ),
      // Título
      const Text('Descubre todo sobre tu canino favorito',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      // Subtítulo
      const Text('Busca razas de perros...', style: TextStyle(color: Colors.white70)),
    ],
  ),
),
```

**`Colors.white70`** → blanco con 70% de opacidad. Flutter tiene atajos para opacidades comunes: `white54`, `white70`, `white`.

---

### El TextField con botón de buscar

```dart
Row(
  children: [
    Expanded(  // el TextField ocupa todo el espacio restante
      child: TextField(
        controller: _searchController,
        onChanged: _onQueryChanged,       // se llama al escribir
        onSubmitted: _onSearchSubmitted,  // se llama al presionar Enter
        textInputAction: TextInputAction.search,  // ← cambia el botón del teclado a 🔍
        decoration: InputDecoration(
          hintText: 'Ej. Terrier, Golden, Bulldog...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(  // ← botón X solo si hay texto
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();  // ← limpiar campo
                    });
                  },
                )
              : null,
        ),
      ),
    ),
    const SizedBox(width: 12),
    Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => _onSearchSubmitted(_searchController.text),
      ),
    ),
  ],
),
```

**`textInputAction: TextInputAction.search`** → cambia el botón de "Enter" del teclado del celular a un ícono de búsqueda 🔍, que al presionarlo llama a `onSubmitted`.

**`suffixIcon: _searchController.text.isNotEmpty ? IconButton(...) : null`** → condicionalmente muestra el botón de limpiar (X) solo cuando hay texto. Pero hay un **detalle importante**: esto NO se actualiza automáticamente porque `_searchController.text` no está dentro de un `setState`. Para que funcione correctamente habría que agregar un listener.

---

### Los ActionChips — Búsquedas rápidas

```dart
Wrap(
  spacing: 8,
  runSpacing: 10,
  children: _quickSearches.map((tag) {
    return ActionChip(
      avatar: const Icon(Icons.pets, size: 14, color: AppTheme.primaryColor),
      label: Text(tag),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      backgroundColor: Colors.amber.shade50,
      side: BorderSide(color: Colors.amber.shade200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _searchController.text = tag;  // pone el texto en el campo
        _onSearchSubmitted(tag);        // navega a resultados
      },
    );
  }).toList(),
),
```

**`ActionChip`** → un chip que se puede presionar. Al tocarlo, establece el texto del campo de búsqueda al nombre del chip y navega a los resultados.

**`_quickSearches.map((tag) { ... }).toList()`** → transforma la lista de strings en una lista de widgets `ActionChip`.

---

### La nota informativa al final

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.amber.shade50.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.amber.shade200),
  ),
  child: Row(
    children: [
      const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'API REST: Consumiendo endpoint GET /breeds/search con autenticación x-api-key.',
          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
        ),
      ),
    ],
  ),
),
```

Esta es una nota educativa que explica qué endpoint de API usa la pantalla.

---

## Flujo de interacción completo

```
App abre → build() se ejecuta → se muestra el Scaffold

Usuario toca TextField
→ Teclado aparece
→ Usuario empieza a escribir "Golden"
→ _onQueryChanged("Golden") se llama (debounce timer se reinicia)

Usuario escribe completo y presiona 🔍 en el teclado
→ _onSearchSubmitted("Golden") se llama
→ cleanQuery = "Golden"
→ Navigator.push(SearchResultsScreen(initialQuery: "Golden"))

O el usuario toca el chip "Golden"
→ ActionChip.onPressed()
→ _searchController.text = "Golden"
→ _onSearchSubmitted("Golden")
→ Navigator.push(SearchResultsScreen(initialQuery: "Golden"))
```

---

## Puntos clave de esta pantalla

| Concepto | Ejemplo |
|----------|---------|
| StatefulWidget | Tiene controller y timer que gestionar |
| TextEditingController | Lee/escribe el campo de búsqueda |
| dispose() | Limpia controller y timer al salir |
| Navigator.push | Navega a SearchResultsScreen con el query |
| Wrap + ActionChip | Chips de búsqueda rápida |
| SingleChildScrollView | La pantalla puede hacer scroll |
| LinearGradient | Degradado naranja del banner |
| onSubmitted | Buscar al presionar Enter en el teclado |

---

*Siguiente: `08_pantalla2_resultados.md` — SearchResultsScreen con FutureBuilder 📋*
