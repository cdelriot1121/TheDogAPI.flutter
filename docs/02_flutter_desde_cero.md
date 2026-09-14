# 02 — Flutter desde Cero 🎨

> **Flutter = framework para construir UIs.** Todo en Flutter es un **Widget**. En este archivo aprendes los widgets fundamentales que usa el proyecto, cómo funciona el estado, y cómo navegar entre pantallas.

---

## ¿Qué es Flutter?

Flutter es un **framework de UI** hecho por Google. Con un solo código puedes hacer una app para:
- 📱 Android
- 🍎 iOS
- 🌐 Web
- 🖥️ Windows, macOS, Linux

**La idea central:** Tu app es un árbol de **Widgets** (bloques visuales). Cuando el estado cambia, Flutter reconstruye solo los widgets necesarios.

---

## 1. ¿Qué es un Widget?

Un Widget es **cualquier cosa visual** en la pantalla: un botón, un texto, una imagen, un padding, un color de fondo... **todo es un widget**.

```dart
// El widget más simple posible:
Text('Hola mundo')

// Un widget que contiene otro:
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hola mundo con padding'),
)

// Un widget con varios hijos:
Column(
  children: [
    Text('Línea 1'),
    Text('Línea 2'),
    Text('Línea 3'),
  ],
)
```

---

## 2. StatelessWidget — Widget sin estado

Un `StatelessWidget` se construye una vez y **nunca cambia**. Solo depende de los datos que recibe.

```dart
class MiTexto extends StatelessWidget {
  final String texto;
  
  const MiTexto({super.key, required this.texto});
  
  @override
  Widget build(BuildContext context) {
    // build() devuelve cómo se ve este widget
    return Text(texto, style: TextStyle(fontSize: 20));
  }
}

// Uso:
MiTexto(texto: 'Hola')
```

### En el proyecto:
```dart
// DogCard es StatelessWidget porque solo MUESTRA datos, no los cambia
class DogCard extends StatelessWidget {
  final BreedModel breed;
  final VoidCallback onTap;
  
  const DogCard({super.key, required this.breed, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return Card(...);  // muestra la tarjeta con los datos de 'breed'
  }
}
```

---

## 3. StatefulWidget — Widget con estado

Un `StatefulWidget` puede **cambiar en el tiempo** (cuando el usuario interactúa, o cuando llegan datos).

Tiene dos clases:
1. La clase del widget (inmutable)
2. La clase del estado `_NombreState` (mutable, donde vive la lógica)

```dart
class Contador extends StatefulWidget {
  const Contador({super.key});
  
  @override
  State<Contador> createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
  int _cuenta = 0;  // Estado interno
  
  void _incrementar() {
    setState(() {         // ← IMPORTANTE: setState() redibuja el widget
      _cuenta++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Cuenta: $_cuenta'),
        ElevatedButton(
          onPressed: _incrementar,
          child: Text('Sumar'),
        ),
      ],
    );
  }
}
```

### `setState()` — la clave del estado en Flutter

`setState()` le dice a Flutter: *"algo cambió, vuelve a dibujar este widget"*.
- Sin `setState()`: la variable cambia pero la pantalla NO se actualiza visualmente.
- Con `setState()`: Flutter redibuja el widget con los nuevos valores.

### En el proyecto:
```dart
// En search_results_screen.dart
class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<BreedModel>> _breedsFuture;  // Estado: el Future de resultados
  
  void _fetchResults() {
    setState(() {  // ← le dice a Flutter que redibuje
      _breedsFuture = _apiService.searchBreeds(_currentQuery);
    });
  }
}
```

---

## 4. El ciclo de vida de un StatefulWidget

```
createState()   → se crea el objeto State
      ↓
initState()     → se ejecuta UNA VEZ al inicio (ideal para cargar datos)
      ↓
build()         → se ejecuta CADA VEZ que se llama setState()
      ↓
dispose()       → se ejecuta cuando el widget desaparece (ideal para limpiar recursos)
```

### En el proyecto:
```dart
// En search_results_screen.dart
@override
void initState() {
  super.initState();
  _currentQuery = widget.initialQuery;  // recibe dato del widget padre
  _searchController.text = _currentQuery;
  _fetchResults();  // ← carga datos al inicio (UNA VEZ)
}

@override
void dispose() {
  _searchController.dispose();  // ← limpia recursos al salir
  super.dispose();
}
```

---

## 5. Scaffold — La estructura base de una pantalla

`Scaffold` es el "esqueleto" de cada pantalla. Tiene partes opcionales:

```dart
Scaffold(
  appBar: AppBar(title: Text('Mi App')),  // barra superior
  body: Center(child: Text('Contenido')), // contenido principal
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
  drawer: Drawer(...),   // menú lateral
  bottomNavigationBar: BottomNavigationBar(...),
)
```

### En el proyecto:
```dart
// En search_results_screen.dart
return Scaffold(
  appBar: AppBar(
    title: const Text('Pantalla 2: Resultados'),
  ),
  body: SafeArea(     // ← SafeArea evita que el contenido quede debajo de la barra de estado del celular
    child: Column(
      children: [
        // barra de búsqueda
        // área de resultados
      ],
    ),
  ),
);
```

---

## 6. Layouts — Cómo organizar widgets

### Column — apila widgets verticalmente (de arriba a abajo)
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // alineación horizontal
  mainAxisAlignment: MainAxisAlignment.center,   // alineación vertical
  children: [
    Text('Arriba'),
    Text('Medio'),
    Text('Abajo'),
  ],
)
```

### Row — pone widgets horizontalmente (de izquierda a derecha)
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Izquierda'),
    Icon(Icons.pets),
    Text('Derecha'),
  ],
)
```

### Stack — superpone widgets (uno encima de otro)
```dart
Stack(
  children: [
    Image.network('url_imagen'),  // fondo
    Positioned(                  // encima, en posición específica
      top: 10,
      right: 10,
      child: Badge(),
    ),
  ],
)
```

### En el proyecto:
```dart
// En dog_card.dart — Stack para la imagen con badge encima
Stack(
  children: [
    Container(
      height: 190,
      child: Image.network(imageUrl),  // imagen de fondo
    ),
    Positioned(                        // badge de grupo de raza encima
      top: 12,
      right: 12,
      child: Container(child: Text(breed.breedGroup!)),
    ),
  ],
)
```

---

## 7. Container — La caja universal

`Container` es un widget súper flexible. Puede tener color, tamaño, padding, bordes, sombras...

```dart
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),       // espacio INTERNO
  margin: EdgeInsets.only(bottom: 8), // espacio EXTERNO
  decoration: BoxDecoration(
    color: Colors.amber,
    borderRadius: BorderRadius.circular(12), // bordes redondeados
    boxShadow: [
      BoxShadow(color: Colors.black26, blurRadius: 8),
    ],
    border: Border.all(color: Colors.orange),
  ),
  child: Text('Dentro del container'),
)
```

### En el proyecto:
```dart
// En breed_search_screen.dart — el banner hero naranja
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(       // degradado de colores
      colors: [Color(0xFFFF6F00), Color(0xFFFF9E80)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Column(children: [...]),
)
```

---

## 8. Expanded y Flexible — Repartir espacio

Dentro de `Row` o `Column`, `Expanded` hace que un widget ocupe **todo el espacio disponible**.

```dart
Row(
  children: [
    Expanded(
      child: TextField(...),  // ocupa todo el ancho disponible
    ),
    SizedBox(width: 12),      // espacio fijo
    ElevatedButton(           // tamaño natural
      child: Text('Buscar'),
    ),
  ],
)
```

### En el proyecto:
```dart
// En search_results_screen.dart — barra de búsqueda
Row(
  children: [
    Expanded(
      child: TextField(controller: _searchController, ...), // TextField flexible
    ),
    const SizedBox(width: 8),   // espacio fijo de 8px
    ElevatedButton(              // botón de tamaño fijo
      onPressed: () => _onNewSearch(_searchController.text),
      child: const Icon(Icons.search),
    ),
  ],
)
```

---

## 9. ListView.builder — Listas eficientes

Para mostrar muchos elementos, usas `ListView.builder`. Solo construye los widgets que están visibles en pantalla.

```dart
ListView.builder(
  itemCount: 50,  // cuántos elementos hay
  itemBuilder: (context, index) {
    // se llama para cada elemento visible
    return ListTile(
      title: Text('Elemento $index'),
    );
  },
)
```

### En el proyecto:
```dart
// En search_results_screen.dart — lista de razas
ListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  itemCount: breeds.length,  // un elemento por raza
  itemBuilder: (context, index) {
    final breed = breeds[index];  // obtener la raza de este índice
    return DogCard(
      breed: breed,
      onTap: () { /* navegar al detalle */ },
    );
  },
)
```

---

## 10. FutureBuilder — Mostrar datos asíncronos

`FutureBuilder` es un widget que construye su UI según el estado de un `Future`:
- Mientras carga: muestra un spinner
- Si hay error: muestra el error
- Si tiene datos: muestra los datos

```dart
FutureBuilder<String>(
  future: obtenerDatos(),  // el Future que esperar
  builder: (context, snapshot) {
    // snapshot contiene el estado actual del Future
    
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();  // cargando...
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');  // error
    }
    
    // ¡Datos disponibles!
    return Text(snapshot.data ?? 'Sin datos');
  },
)
```

### Estados del `snapshot`:
| Estado | Qué significa |
|--------|---------------|
| `ConnectionState.waiting` | El Future todavía está en proceso |
| `snapshot.hasError` | El Future terminó con un error |
| `snapshot.hasData` | El Future terminó exitosamente |
| `snapshot.data` | Los datos que devolvió el Future |

### En el proyecto:
```dart
// En search_results_screen.dart
FutureBuilder<List<BreedModel>>(
  future: _breedsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator()); // spinner
    }
    
    if (snapshot.hasError) {
      return ErrorStateWidget(
        errorMessage: snapshot.error.toString(),
        onRetry: _fetchResults,
      );
    }
    
    final breeds = snapshot.data ?? [];
    
    if (breeds.isEmpty) {
      return EmptyStateWidget(query: _currentQuery, onReset: () {...});
    }
    
    return ListView.builder(...);  // ¡muestra los resultados!
  },
)
```

---

## 11. Image.network — Mostrar imágenes de internet

```dart
Image.network(
  'https://ejemplo.com/imagen.jpg',
  fit: BoxFit.cover,  // cómo ajustar la imagen al espacio
  
  // Mientras carga:
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;  // ya cargó, muestra la imagen
    return CircularProgressIndicator();          // todavía cargando
  },
  
  // Si hay error (imagen no encontrada, sin internet):
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

### En el proyecto:
```dart
// En dog_card.dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
            : null,  // muestra el % de carga si lo conoce
        color: AppTheme.primaryColor,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return _buildImagePlaceholder(); // placeholder si falla
  },
)
```

---

## 12. Navigator — Navegar entre pantallas

Flutter usa un **stack de pantallas** (como una pila de hojas). Puedes:
- `push` → ir a una nueva pantalla (apilar encima)
- `pop` → volver a la anterior (quitar de la pila)

```dart
// Ir a una nueva pantalla:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NuevaPantalla(),
  ),
);

// Volver a la pantalla anterior:
Navigator.pop(context);

// Ir y pasar datos:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetallePantalla(datos: misDatos),
  ),
);
```

### En el proyecto:
```dart
// En breed_search_screen.dart — navegar a resultados con el query
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchResultsScreen(initialQuery: cleanQuery),
  ),
);

// En search_results_screen.dart — navegar al detalle pasando la raza
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DogDetailScreen(breed: breed),
  ),
);

// Volver atrás (cuando no hay resultados):
Navigator.pop(context);  // ← AppBar ya tiene una flecha atrás automática
```

---

## 13. TextField — Campo de texto

```dart
// Necesitas un controlador para leer/escribir el texto
final TextEditingController _controller = TextEditingController();

TextField(
  controller: _controller,
  onChanged: (value) {
    // Se llama cada vez que el usuario escribe algo
    print('Texto: $value');
  },
  onSubmitted: (value) {
    // Se llama cuando el usuario presiona Enter/buscar
    print('Enviado: $value');
  },
  decoration: InputDecoration(
    hintText: 'Escribe aquí...',
    prefixIcon: Icon(Icons.search),
  ),
)

// Leer el texto actual:
String texto = _controller.text;

// Limpiar el campo:
_controller.clear();

// Importante: siempre limpiar en dispose()
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 14. Wrap — Tags que se acomodan solos

`Wrap` es como `Row`, pero cuando no caben más elementos, los pasa a la siguiente fila.

```dart
Wrap(
  spacing: 8,     // espacio horizontal entre elementos
  runSpacing: 8,  // espacio vertical entre filas
  children: [
    Chip(label: Text('Friendly')),
    Chip(label: Text('Active')),
    Chip(label: Text('Intelligent')),
    Chip(label: Text('Energetic')),
    // Si no caben en una línea, van a la siguiente
  ],
)
```

### En el proyecto:
```dart
// En dog_detail_screen.dart — tags de temperamento
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: widget.breed.temperamentTags.map((tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag),
    );
  }).toList(),
)
```

---

## 15. Colores en Flutter

Los colores se especifican en formato hexadecimal:
- `Color(0xFFRRGGBB)` — el primer FF es la opacidad (FF = 100%)
- `Colors.amber` — colores predefinidos de Material Design
- `Colors.amber.shade100` — tonos más claros (100-900)

```dart
Color rojo = Color(0xFFFF0000);    // Rojo puro
Color naranja = Color(0xFFFF6F00); // Naranja del proyecto
Color transparente = Color(0x00000000); // Totalmente transparente

// Agregar opacidad:
Color naranjaSemiTransparente = AppTheme.primaryColor.withValues(alpha: 0.3);
// 0.0 = completamente transparente, 1.0 = completamente opaco
```

---

## Resumen — Widgets más usados del proyecto

| Widget | Para qué sirve |
|--------|----------------|
| `StatelessWidget` | Widget que no cambia |
| `StatefulWidget` | Widget que puede cambiar (con `setState`) |
| `Scaffold` | Estructura base de una pantalla |
| `AppBar` | Barra superior de la pantalla |
| `SafeArea` | Evita superposición con status bar |
| `Column` | Apila widgets verticalmente |
| `Row` | Alinea widgets horizontalmente |
| `Stack` | Superpone widgets |
| `Container` | Caja con color, tamaño, bordes, sombras |
| `Expanded` | Ocupa el espacio restante disponible |
| `SizedBox` | Espacio fijo o tamaño específico |
| `Padding` | Agrega espacio interno |
| `Text` | Muestra texto |
| `Icon` | Muestra un ícono de Material |
| `Image.network` | Muestra imagen de URL |
| `ListView.builder` | Lista eficiente de elementos |
| `FutureBuilder` | Reacciona a Futures (async) |
| `TextField` | Campo de texto editable |
| `ElevatedButton` | Botón elevado con color |
| `IconButton` | Botón solo con ícono |
| `Card` | Tarjeta con sombra y bordes |
| `CircularProgressIndicator` | Spinner de carga circular |
| `Wrap` | Fila que se envuelve en múltiples líneas |
| `Navigator.push` | Navegar a nueva pantalla |
| `Navigator.pop` | Volver a la pantalla anterior |

---

*Siguiente: `03_arquitectura_y_estructura.md` — cómo está organizado el código 🏗️*
