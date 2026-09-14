# 09 — Pantalla 3: Detalle del Perro (DogDetailScreen) 🐕

> La pantalla más elaborada del proyecto. Aquí aprendes: **SliverAppBar** (header colapsable con foto), **CustomScrollView**, **Sliver widgets**, **Dialog.fullscreen**, **InteractiveViewer** (zoom en imágenes), y cómo construir widgets auxiliares privados dentro de una clase State.

---

## ¿Qué muestra esta pantalla?

```
┌──────────────────────────────────┐
│ [← ] [────────────────────────] │ ← AppBar fijo al hacer scroll
│                                  │
│  ┌──────────────────────────┐   │
│  │     🖼️ FOTO DEL PERRO    │   │ ← Header expandido con foto
│  │     (320px alto)         │   │
│  │                          │   │
│  │  Golden Retriever        │   │ ← Título sobre la foto
│  │              [⤡ zoom]   │   │ ← Botón pantalla completa
│  └──────────────────────────┘   │
│                                  │
│  ✓ Pantalla 3: Perfil Canino    │ ← Badge indicador
│                                  │
│  [⚖️ Peso Métrico] [📏 Altura]  │ ← Cards métricas en grid 2x2
│  [❤️ Vida]         [🏷️ Grupo]  │
│                                  │
│  Temperamento y Personalidad     │
│  [Intelligent][Friendly][Active] │ ← Tags de temperamento
│  [Reliable][Kind][Confident]     │
│                                  │
│  Origen de la Raza               │
│  🚩 United Kingdom (GB)          │
│                                  │
│  Criado Para                     │
│  💼 Retrieving fowl, upland...   │
│                                  │
│  Descripción General             │
│  📄 The Golden Retriever is...   │
│                                  │
│  Historia de la Raza             │
│  📚 The breed was developed...   │
│                                  │
│  Detalles de la API:             │ ← Info técnica
│  • ID Raza: 95                   │
│  • Reference Image ID: BJa4...   │
└──────────────────────────────────┘
```

---

## 📄 Análisis del código

**Archivo:** [`lib/features/dog_search/presentation/screens/dog_detail_screen.dart`](file:///C:/Users/Lap-careu/Desktop/TheDogAPI.flutter/lib/features/dog_search/presentation/screens/dog_detail_screen.dart)

### La clase StatefulWidget

```dart
class DogDetailScreen extends StatefulWidget {
  final BreedModel breed;   // recibe la raza desde SearchResultsScreen

  const DogDetailScreen({
    super.key,
    required this.breed,    // obligatorio
  });

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}
```

Recibe `BreedModel` con todos los datos de la raza. El estado agrega la foto extra (`DogImageModel?`).

---

### El estado interno

```dart
class _DogDetailScreenState extends State<DogDetailScreen> {
  final DogApiService _apiService = DogApiService();
  DogImageModel? _imageDetail;  // null hasta que cargue, puede quedarse null si falla
```

`_imageDetail` empieza en `null`. Cuando carga desde la API, se actualiza con `setState`.

---

### `initState()` — Cargar la imagen extra

```dart
@override
void initState() {
  super.initState();
  _loadImageDetails();  // inicia la carga de la imagen al entrar
}

Future<void> _loadImageDetails() async {
  if (widget.breed.referenceImageId != null &&
      widget.breed.referenceImageId!.isNotEmpty) {
    final detail = await _apiService.getImageDetails(widget.breed.referenceImageId!);
    if (mounted) {             // ← VERIFICACIÓN CRUCIAL
      setState(() {
        _imageDetail = detail; // actualiza con los datos de la imagen
      });
    }
  }
}
```

**`if (mounted)`** → verificación de seguridad crítica.

¿Qué es `mounted`? Es una propiedad booleana del `State` que indica si el widget **todavía está en el árbol de widgets**. Si el usuario presiona atrás antes de que la API responda, el widget ya no existe, y llamar `setState` sobre un widget destruido causa un error.

```
Sin mounted:                        Con mounted:
1. initState → _loadImageDetails()  1. initState → _loadImageDetails()
2. Usuario presiona atrás           2. Usuario presiona atrás
3. DogDetailScreen se destruye      3. DogDetailScreen se destruye
4. API responde                     4. API responde
5. setState() ← ERROR!              5. if (mounted) → false → no llamamos setState ✓
```

---

### `_openFullImageDialog` — Imagen en pantalla completa

```dart
void _openFullImageDialog(String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // La imagen con zoom
          Center(
            child: InteractiveViewer(
              minScale: 0.5,   // puede hacer zoom out al 50%
              maxScale: 4.0,   // puede hacer zoom in al 400%
              child: Image.network(
                getImageUrl(imageUrl),
                fit: BoxFit.contain,    // muestra la imagen completa (sin recortar)
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 80,
                ),
              ),
            ),
          ),
          
          // Botón cerrar (X) arriba a la derecha
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),  // cerrar el dialog
            ),
          ),
          
          // Texto de ayuda abajo
          const Positioned(
            bottom: 30, left: 0, right: 0,
            child: Text(
              'Pellizca o arrastra para hacer zoom',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**`showDialog`** → muestra un diálogo modal encima de la pantalla.

**`Dialog.fullscreen`** → ocupa toda la pantalla (diferente al dialog normal que tiene padding).

**`InteractiveViewer`** → permite hacer zoom (pinch-to-zoom) y arrastrar la imagen. Con `minScale` y `maxScale` defines los límites del zoom.

**`Navigator.pop(context)` dentro del dialog** → cierra el dialog (no la pantalla).

---

### `build()` — La pantalla con SliverAppBar

```dart
@override
Widget build(BuildContext context) {
  // Determinar la mejor URL de imagen disponible
  final rawImageUrl = _imageDetail?.url ?? widget.breed.imageUrl;
  // Si _imageDetail cargó (no es null) → usa su URL
  // Si todavía es null o la API falló → usa la URL del breed
  
  final imageUrl = getImageUrl(rawImageUrl);  // aplica proxy CORS si es necesario

  return Scaffold(
    body: CustomScrollView(
      slivers: [
        // SLIVER 1: Header expandible con foto
        SliverAppBar(...),
        
        // SLIVER 2: Contenido scrolleable
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [ /* todos los detalles */ ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

### `CustomScrollView` y Slivers — ¿Qué son?

**El problema con `SingleChildScrollView + AppBar`:**
La `AppBar` normal siempre queda fija arriba. No puedes hacer que se expanda para mostrar una foto grande y luego se colapse al hacer scroll.

**La solución:** `CustomScrollView` con `Slivers`.

Un **Sliver** es un widget que sabe coordinarse con un scroll. La `CustomScrollView` maneja una lista de slivers y los anima juntos.

```
Slivers disponibles:
  SliverAppBar       → AppBar que puede expandirse y colapsarse
  SliverToBoxAdapter → convierte un widget normal en sliver
  SliverList         → lista eficiente (alternativa a ListView)
  SliverGrid         → grid (cuadrícula) de elementos
```

---

### `SliverAppBar` — El header colapsable con foto

```dart
SliverAppBar(
  expandedHeight: 320,  // altura cuando está completamente expandido
  pinned: true,         // se queda fijo arriba cuando colapsado (no desaparece)
  flexibleSpace: FlexibleSpaceBar(
    // Título que aparece cuando está colapsado
    title: Text(
      widget.breed.name,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
        // ↑ sombra en el texto para legibilidad sobre la foto
      ),
    ),
    
    background: Stack(
      fit: StackFit.expand,   // el Stack ocupa todo el espacio del header
      children: [
        // 1. La imagen del perro (tappable para abrir en fullscreen)
        if (imageUrl.isNotEmpty)
          GestureDetector(
            onTap: () => _openFullImageDialog(imageUrl),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,   // recorta para llenar el espacio
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.amber.shade50,
                  child: const Center(child: CircularProgressIndicator(...)),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.amber.shade50,
                child: const Icon(Icons.pets_rounded, size: 80),
              ),
            ),
          )
        else
          Container(  // placeholder si no hay imagen
            color: Colors.amber.shade50,
            child: const Icon(Icons.pets_rounded, size: 80),
          ),
        
        // 2. Degradado oscuro encima de la imagen (para que el texto sea legible)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),  // arriba: oscuro
                  Colors.transparent,                    // centro: claro
                  Colors.black.withValues(alpha: 0.7),  // abajo: oscuro
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],  // posiciones del gradiente
              ),
            ),
          ),
        ),
        
        // 3. Botón de zoom (esquina inferior derecha)
        if (imageUrl.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'zoomBtn',  // tag único para la animación Hero
              backgroundColor: AppTheme.primaryColor,
              onPressed: () => _openFullImageDialog(imageUrl),
              child: const Icon(Icons.fullscreen_rounded, color: Colors.white),
            ),
          ),
      ],
    ),
  ),
),
```

**Comportamiento del `SliverAppBar` con `pinned: true`:**

```
Al abrir la pantalla:          Al hacer scroll hacia arriba:
┌────────────────────┐         ┌────────────────────────────┐
│                    │         │ ← Golden Retriever          │ ← colapsado fijo
│   🖼️ FOTO          │  scroll │─────────────────────────────│
│                    │ ──────→ │                             │
│ Golden Retriever   │         │  Contenido del detalle      │
└────────────────────┘         │  (sigue siendo scrolleable) │
│ Contenido...       │         └─────────────────────────────┘
```

---

### El grid de métricas — `_buildMetricCard`

```dart
Row(
  children: [
    Expanded(
      child: _buildMetricCard(
        icon: Icons.scale_rounded,
        title: 'Peso (Métrico)',
        value: widget.breed.metricWeight != null
            ? '${widget.breed.metricWeight} kg'
            : 'No especificado',
        subtitle: widget.breed.imperialWeight != null
            ? '${widget.breed.imperialWeight} lbs'
            : null,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildMetricCard(
        icon: Icons.straighten_rounded,
        title: 'Altura (Métrica)',
        value: widget.breed.metricHeight != null
            ? '${widget.breed.metricHeight} cm'
            : 'No especificado',
      ),
    ),
  ],
),
```

Dos `Expanded` dentro de un `Row` los hace del **mismo ancho** (cada uno ocupa la mitad).

---

### Widgets auxiliares privados

Dentro de `_DogDetailScreenState` hay 3 métodos que devuelven widgets. Son "componentes privados" de esta pantalla:

```dart
// Widget para el título de cada sección
Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
  );
}

// Widget para una card de métrica (peso, altura, vida, grupo)
Widget _buildMetricCard({
  required IconData icon,
  required String title,
  required String value,
  String? subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ],
    ),
  );
}

// Widget para una tarjeta de información (origen, descripción, etc.)
Widget _buildInfoCard({required IconData icon, required String content}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4))),
      ],
    ),
  );
}
```

**`overflow: TextOverflow.ellipsis`** → si el texto es muy largo, lo corta con `...` en vez de desbordar.

**`crossAxisAlignment: CrossAxisAlignment.start`** en `Row` → alinea los hijos en la parte superior (cuando tienen diferentes alturas).

**`height: 1.4`** en `TextStyle` → interlineado de 1.4 (40% más que el tamaño de la fuente). Hace el texto más legible.

---

## Resumen de técnicas de esta pantalla

| Técnica | Descripción |
|---------|-------------|
| `CustomScrollView + Slivers` | Permite el header colapsable y el scroll coordinado |
| `SliverAppBar` | Header que se expande/colapsa con la foto del perro |
| `FlexibleSpaceBar` | Contenido del SliverAppBar con imagen de fondo |
| `pinned: true` | El AppBar queda fijo al colapsar (no desaparece) |
| `if (mounted)` | Seguridad al hacer setState después de async |
| `showDialog` | Mostrar el diálogo de imagen completa |
| `Dialog.fullscreen` | Diálogo que ocupa toda la pantalla |
| `InteractiveViewer` | Zoom con pinch gesture |
| `Stack + Positioned.fill` | Degradado encima de la imagen para legibilidad |
| `_buildMetricCard()` | Helper privado para no repetir código de UI |
| `_buildInfoCard()` | Helper privado para tarjetas de información |
| `if (...) ...[widget]` | Secciones condicionales (solo se muestran si hay datos) |
| `?? 'No especificado'` | Valor por defecto para campos que pueden ser null |

---

*Siguiente: `10_widgets_reutilizables.md` — DogCard, EmptyState, ErrorState 🧩*
