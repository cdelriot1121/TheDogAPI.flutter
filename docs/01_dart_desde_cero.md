# 01 — Dart desde Cero 🎯

> **No sabes nada de Dart. Perfecto.** Este archivo te explica TODO el lenguaje que necesitas para entender el proyecto, con ejemplos del código real de `lib/`.

---

## ¿Qué es Dart?

Dart es el **lenguaje de programación** que usa Flutter. Es parecido a Java, JavaScript o C#. Es fuertemente tipado (tienes que decirle el tipo de cada variable), pero tiene muchas comodidades modernas.

---

## 1. Tipos de datos básicos

```dart
// Números enteros
int edad = 25;
int cantidad = 100;

// Números decimales
double precio = 19.99;

// Texto (Strings)
String nombre = 'Golden Retriever';
String descripcion = "Un perro muy amigable";

// Booleanos
bool esActivo = true;
bool estaVacio = false;

// Tipo dinámico (puede cambiar)
dynamic cualquierCosa = 42;
cualquierCosa = 'ahora soy texto'; // válido
```

### En el proyecto lo ves en:
```dart
// En breed_model.dart
final String id;           // texto que nunca cambia
final String name;
final String? lifeSpan;    // El ? significa que PUEDE ser null (nulo)
final int? width;          // número entero que puede ser null
```

---

## 2. El signo `?` — Nullable (puede ser nulo)

En Dart moderno, por defecto las variables **NO pueden ser null**. Si quieres que puedan ser null, pones `?` al final del tipo.

```dart
String nombre = 'Buddy';    // NUNCA puede ser null
String? apodo = null;       // SÍ puede ser null (opcional)

// Para usar un valor nullable, debes verificar:
if (apodo != null) {
  print(apodo);             // aquí ya sabe que no es null
}

// O usar el operador ?. (safe call)
print(apodo?.length);       // si apodo es null, devuelve null en vez de error

// O usar ?? (si es null, usa este otro valor)
String resultado = apodo ?? 'Sin apodo';
```

### En el proyecto:
```dart
// En breed_model.dart — getter imageUrl
String? get imageUrl {
  if (directImageUrl != null && directImageUrl!.isNotEmpty) {
    return directImageUrl;  // puede devolver null si no hay imagen
  }
  // ...
}
```

El `!` después de `directImageUrl!` le dice a Dart: *"confía en mí, sé que esto no es null"*

---

## 3. Variables: `var`, `final`, `const`

```dart
// var — infiere el tipo, puede reasignarse
var query = 'Golden';
query = 'Bulldog';          // OK

// final — se asigna UNA vez, no puede cambiar
final String raza = 'Terrier';
// raza = 'Poodle';         // ERROR — ya está definida

// const — constante en tiempo de compilación
const int maxResultados = 50;
const Color rojo = Color(0xFFFF0000);
```

### En el proyecto:
```dart
// En app_theme.dart — colores constantes de la app
static const Color primaryColor = Color(0xFFFF6F00);  // Naranja
static const Color secondaryColor = Color(0xFF3E2723); // Marrón

// En breed_model.dart — los campos del modelo son final
final String id;
final String name;
```

---

## 4. Funciones

```dart
// Función básica
String saludar(String nombre) {
  return 'Hola, $nombre!';
}

// Función con valor por defecto
String buscar(String query, {int limite = 10}) {
  return 'Buscando $query con límite $limite';
}
buscar('Golden');              // limite = 10 por defecto
buscar('Golden', limite: 5);  // limite = 5

// Función flecha (=> ) — para funciones de una sola línea
String obtenerUrl(String id) => 'https://api.example.com/$id';

// Función anónima (lambda / arrow function)
final multiplicar = (int a, int b) => a * b;
```

### En el proyecto:
```dart
// En api_constants.dart — funciones flecha que generan URLs
static String searchBreedsUrl(String query) =>
    '$baseUrl/breeds/search?q=$query';

static String imageDetailUrl(String imageId) =>
    '$baseUrl/images/$imageId';
```

---

## 5. La interpolación de Strings con `$`

```dart
String nombre = 'Buddy';
int edad = 3;

// Con $variable
print('Mi perro se llama $nombre');
// → "Mi perro se llama Buddy"

// Con ${expresión} para expresiones complejas
print('Tiene ${edad * 12} meses');
// → "Tiene 36 meses"
```

### En el proyecto:
```dart
// En search_results_screen.dart
Text('Consultando TheDogAPI para "$_currentQuery"...')
// Si _currentQuery = "Golden" → "Consultando TheDogAPI para "Golden"..."

// En api_constants.dart
'$baseUrl/breeds/search?q=$query'
// Si query = "terrier" → "https://api.thedogapi.com/v1/breeds/search?q=terrier"
```

---

## 6. Listas (List)

```dart
// Lista de strings
List<String> razas = ['Golden', 'Bulldog', 'Poodle'];

// Acceder a elementos
print(razas[0]);   // → 'Golden'
print(razas.length); // → 3

// Agregar, quitar
razas.add('Husky');
razas.remove('Poodle');

// Recorrer con for
for (String raza in razas) {
  print(raza);
}

// Transformar con .map()
List<String> enMayusculas = razas.map((r) => r.toUpperCase()).toList();
// → ['GOLDEN', 'BULLDOG', 'HUSKY']

// Filtrar con .where()
List<String> solo4Letras = razas.where((r) => r.length == 4).toList();
// → ['Husky'... etc. si tiene 4 letras]
```

### En el proyecto:
```dart
// En breed_model.dart — parsear temperamento de texto a lista
List<String> get temperamentTags {
  return temperament!
      .split(',')           // divide "Friendly, Active, Loyal" en lista
      .map((e) => e.trim()) // quita espacios a cada elemento
      .where((e) => e.isNotEmpty) // filtra los vacíos
      .toList();            // convierte el resultado a List
}
// Resultado: ['Friendly', 'Active', 'Loyal']
```

---

## 7. Mapas (Map) — como diccionarios JSON

```dart
// Un Map es clave → valor
Map<String, dynamic> perro = {
  'nombre': 'Buddy',
  'edad': 3,
  'esActivo': true,
};

// Acceder a valores
String nombre = perro['nombre'];   // → 'Buddy'
int edad = perro['edad'];          // → 3

// Acceso seguro (puede ser null si la clave no existe)
var raza = perro['raza'];          // → null (no existe)
```

### En el proyecto:
```dart
// En breed_model.dart — parsear JSON de la API
factory BreedModel.fromJson(Map<String, dynamic> json) {
  // json es el diccionario que viene de la API:
  // { "id": "1", "name": "Retriever", "weight": {"metric": "30"} }
  
  if (json['weight'] is Map) {        // si 'weight' es un mapa anidado
    mWeight = json['weight']['metric']?.toString(); // accede al sub-valor
  }
}
```

---

## 8. Clases y objetos

```dart
// Definir una clase
class Perro {
  // Propiedades (campos)
  final String nombre;
  final int edad;
  String? raza;    // opcional
  
  // Constructor
  Perro({
    required this.nombre,  // requerido
    required this.edad,    // requerido
    this.raza,             // opcional (puede ser null)
  });
  
  // Método (función dentro de la clase)
  String presentarse() {
    return 'Soy $nombre, tengo $edad años';
  }
  
  // Getter — propiedad calculada
  bool get esCachorro => edad < 2;
}

// Crear un objeto
Perro miPerro = Perro(nombre: 'Buddy', edad: 1);
print(miPerro.presentarse()); // → "Soy Buddy, tengo 1 años"
print(miPerro.esCachorro);    // → true
```

### En el proyecto:
```dart
// BreedModel es exactamente una clase así:
class BreedModel {
  final String id;
  final String name;
  final String? lifeSpan;  // opcional
  
  BreedModel({
    required this.id,      // requerido
    required this.name,    // requerido
    this.lifeSpan,         // opcional
  });
  
  // Getter calculado
  String? get imageUrl {
    if (directImageUrl != null) return directImageUrl;
    // ...
  }
  
  // Getter que devuelve una lista
  List<String> get temperamentTags { ... }
}
```

---

## 9. Factory Constructor — `factory`

Es un constructor especial que puede devolver un objeto ya construido. Se usa mucho para parsear JSON.

```dart
class Perro {
  final String nombre;
  final int edad;
  
  Perro({required this.nombre, required this.edad});
  
  // factory = constructor que procesa datos antes de crear el objeto
  factory Perro.fromJson(Map<String, dynamic> json) {
    return Perro(
      nombre: json['nombre'] ?? 'Sin nombre',  // ?? = valor por defecto
      edad: json['edad'] ?? 0,
    );
  }
}

// Uso:
Map<String, dynamic> jsonDeLaAPI = {'nombre': 'Buddy', 'edad': 3};
Perro buddy = Perro.fromJson(jsonDeLaAPI);
```

### En el proyecto:
```dart
// En breed_model.dart
factory BreedModel.fromJson(Map<String, dynamic> json) {
  return BreedModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Raza Desconocida',
    lifeSpan: json['life_span']?.toString(),
    // ...
  );
}
```

---

## 10. Static — miembros de clase sin instancia

`static` significa que puedes usar algo sin crear un objeto de la clase.

```dart
class MathHelper {
  static const double PI = 3.14159;
  
  static double calcularArea(double radio) {
    return PI * radio * radio;
  }
}

// Sin crear ningún objeto:
print(MathHelper.PI);              // → 3.14159
print(MathHelper.calcularArea(5)); // → 78.54
```

### En el proyecto:
```dart
// En api_constants.dart — todo es static
class ApiConstants {
  static const String baseUrl = 'https://api.thedogapi.com/v1';
  
  static Map<String, String> get headers => { ... };
  
  static String searchBreedsUrl(String query) => '$baseUrl/...';
}

// Se usa así (sin crear objeto):
ApiConstants.baseUrl          // ← directo
ApiConstants.searchBreedsUrl('Golden')
```

---

## 11. Async/Await y Future — programación asíncrona

En Dart, cuando algo tarda (como una llamada a internet), usas `Future` para no bloquear la app.

```dart
// Future<T> = "una promesa de que devolveré un T en el futuro"
Future<String> obtenerDatosDeInternet() async {
  // await = "espera aquí sin bloquear la app"
  await Future.delayed(Duration(seconds: 2)); // simula espera
  return 'Datos obtenidos!';
}

// Para usar una función async:
void main() async {
  print('Iniciando...');
  String resultado = await obtenerDatosDeInternet();
  print(resultado); // → "Datos obtenidos!" (2 segundos después)
  print('Listo!');
}
```

### En el proyecto:
```dart
// En dog_api_service.dart — función que llama a internet
Future<List<BreedModel>> searchBreeds(String query) async {
  // await espera la respuesta HTTP sin congelar la app
  final response = await _client.get(url, headers: headers)
      .timeout(const Duration(seconds: 10));
  
  if (response.statusCode == 200) {
    // procesar y devolver la lista
    return jsonList.map((item) => BreedModel.fromJson(item)).toList();
  } else {
    throw DogApiException('Error...');
  }
}
```

---

## 12. Try/Catch — manejo de errores

```dart
try {
  // código que puede fallar
  final resultado = await llamarAInternet();
  print(resultado);
} on TimeoutException {
  // captura un tipo específico de error
  print('Se tardó demasiado');
} catch (e) {
  // captura cualquier otro error
  print('Error: $e');
} finally {
  // esto SIEMPRE se ejecuta (con o sin error)
  print('Fin del intento');
}

// Lanzar un error personalizado:
throw MiExcepcion('Algo salió mal');
```

### En el proyecto:
```dart
// En dog_api_service.dart — excepción personalizada
class DogApiException implements Exception {
  final String message;
  final int? statusCode;
  
  DogApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

// Y se usa en el servicio:
try {
  final response = await _client.get(url, headers: headers)
      .timeout(const Duration(seconds: 10));
  // ...
} on DogApiException {
  rethrow;  // re-lanza el mismo error
} catch (e) {
  throw DogApiException('Error de conexión...');
}
```

---

## 13. Spread operator `...` y colecciones condicionales

```dart
// ... agrega los elementos de una lista dentro de otra
List<String> base = ['a', 'b'];
List<String> extra = ['c', 'd'];
List<String> todo = [...base, ...extra]; // → ['a', 'b', 'c', 'd']

// if dentro de listas/widgets
bool mostrar = true;
List<String> items = [
  'siempre',
  if (mostrar) 'condicional',  // solo si mostrar == true
  'también siempre',
];
```

### En el proyecto:
```dart
// En dog_detail_screen.dart — secciones que solo se muestran si hay datos
Column(
  children: [
    // Stats cards (siempre)
    _buildMetricCard(...),
    
    // Temperamento (solo si hay tags)
    if (widget.breed.temperamentTags.isNotEmpty) ...[
      const Text('Temperamento'),
      Wrap(children: [...]),  // muestra los tags
    ],
    
    // Origen (solo si existe)
    if (widget.breed.origin != null && widget.breed.origin!.isNotEmpty) ...[
      _buildSectionTitle('Origen de la Raza'),
      _buildInfoCard(content: widget.breed.origin!),
    ],
  ],
)
```

---

## 14. Imports — cómo se conectan los archivos

```dart
// Importar un paquete externo (de pub.dev)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // alias 'as'

// Importar un archivo del proyecto (rutas relativas)
import '../../data/models/breed_model.dart';
import '../../../../core/theme/app_theme.dart';

// Los '../' suben un nivel de carpeta
// '../../' = sube 2 carpetas
// '../../../../' = sube 4 carpetas
```

### En el proyecto:
```dart
// En dog_api_service.dart
import 'dart:convert';                          // para json.decode
import 'package:http/http.dart' as http;        // paquete externo
import '../../../../core/constants/api_constants.dart';  // 4 niveles arriba
import '../models/breed_model.dart';            // 1 nivel arriba → models/
```

---

## Resumen rápido — "cheat sheet" de Dart

| Concepto | Ejemplo rápido |
|----------|----------------|
| Variable | `String nombre = 'Buddy';` |
| Nullable | `String? apodo;` — puede ser null |
| Final | `final int id = 1;` — no cambia |
| Const | `const Color rojo = Color(0xFF...);` |
| Función | `String saludar(String n) => 'Hola $n';` |
| Lista | `List<String> razas = ['Golden', 'Poodle'];` |
| Mapa | `Map<String, dynamic> json = {'id': '1'};` |
| Clase | `class Perro { final String nombre; }` |
| Factory | `factory Perro.fromJson(Map json) { ... }` |
| Async | `Future<String> obtener() async { ... }` |
| Await | `String dato = await obtenerDato();` |
| Try/catch | `try { ... } catch(e) { ... }` |
| Null-check | `valor ?? 'default'` |
| Safe call | `objeto?.propiedad` |

---

*Siguiente: `02_flutter_desde_cero.md` — ¡ahora sí, widgets y UI! 🎨*
