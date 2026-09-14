# 03 — Arquitectura y Estructura del Proyecto 🏗️

> **¿Por qué está organizado así?** Este archivo explica la filosofía de diseño del proyecto: "Feature-First" + separación en capas (Data / Presentation). No solo dice *qué* hay, sino *por qué* está donde está.

---

## El problema que resuelve una buena arquitectura

Imagina una app sin organización:
```
lib/
├── todo_en_un_solo_archivo.dart  ← 5000 líneas de código imposible de mantener
```

Ahora imagina que quieres agregar una nueva función: buscar gatos. ¿Dónde lo pones? ¿Cómo sabes qué código reusar?

La arquitectura del proyecto resuelve esto con dos principios:

---

## Principio 1: Feature-First (Por Funcionalidad)

En lugar de organizar por *tipo de archivo* (todos los modelos juntos, todas las pantallas juntas), se organiza por **funcionalidad completa**.

```
❌ Organización tipo → Todo mezclado por tipo
lib/
├── models/          ← todos los modelos de toda la app
├── screens/         ← todas las pantallas de toda la app
├── services/        ← todos los servicios de toda la app

✅ Feature-First → Cada feature es autónoma
lib/
├── features/
│   ├── dog_search/   ← TODA la lógica de búsqueda de razas aquí
│   │   ├── data/
│   │   └── presentation/
│   ├── dog_favorites/ ← si existiera, aquí estaría todo
│   └── user_profile/  ← si existiera, aquí estaría todo
```

**Ventaja:** Si mañana quieres agregar "búsqueda de gatos", creas `features/cat_search/` con su propia `data/` y `presentation/`, sin tocar nada de `dog_search/`.

---

## Principio 2: Separación en Capas

Dentro de cada feature, el código se divide en dos capas:

```
dog_search/
├── data/          ← Capa de DATOS (qué datos hay y de dónde vienen)
│   ├── models/   ← Cómo se representa la información (estructuras)
│   └── services/ ← Cómo se obtienen los datos (APIs, base de datos)
│
└── presentation/  ← Capa de PRESENTACIÓN (lo que el usuario ve)
    ├── screens/  ← Pantallas completas
    └── widgets/  ← Piezas reutilizables de UI
```

**Regla de oro:**
- La capa `data/` **nunca** importa nada de `presentation/`
- La capa `presentation/` **sí** puede importar de `data/`

```
data/ → NO conoce la UI
presentation/ → Conoce y usa data/
```

---

## El rol de `core/`

`core/` contiene cosas que **toda la app necesita**, sin importar la feature.

```
core/
├── constants/
│   └── api_constants.dart    ← URLs base, headers, claves de API
├── theme/
│   └── app_theme.dart        ← Colores, estilos, temas globales
└── utils/
    └── image_helper.dart     ← Funciones de utilidad genéricas
```

**Regla:** Si algo lo necesitan 2+ features, va a `core/`. Si solo lo necesita una feature, va dentro de esa feature.

---

## El archivo `main.dart` — El punto de arranque

```dart
// lib/main.dart
void main() {
  runApp(const TheDogApiApp());  // ← Flutter arranca con esto
}

class TheDogApiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(           // ← Wrapper principal de la app
      title: 'TheDogAPI Explorer',
      theme: AppTheme.lightTheme, // ← usa el tema de core/theme/
      home: const BreedSearchScreen(), // ← primera pantalla
    );
  }
}
```

`MaterialApp` es el widget raíz que configura:
- El título de la app
- El tema visual (colores, fuentes)
- La pantalla inicial
- El sistema de navegación

---

## Diagrama completo de dependencias

```
main.dart
    │
    ├── core/theme/app_theme.dart     (tema visual)
    │
    └── features/dog_search/presentation/screens/
            └── breed_search_screen.dart
                    │
                    └── search_results_screen.dart
                            │
                            ├── data/services/dog_api_service.dart
                            │       │
                            │       ├── data/models/breed_model.dart
                            │       │       └── core/constants/api_constants.dart
                            │       └── data/models/dog_image_model.dart
                            │               └── data/models/breed_model.dart
                            │
                            ├── presentation/widgets/dog_card.dart
                            │       ├── data/models/breed_model.dart
                            │       └── core/utils/image_helper.dart
                            │
                            ├── presentation/widgets/empty_state_widget.dart
                            ├── presentation/widgets/error_state_widget.dart
                            │
                            └── dog_detail_screen.dart
                                    ├── data/models/breed_model.dart
                                    ├── data/models/dog_image_model.dart
                                    ├── data/services/dog_api_service.dart
                                    └── core/utils/image_helper.dart
```

---

## La ruta `../../../../` — Cómo leer imports relativos

Cuando ves `../../../../core/...`, son **puntos que suben niveles de carpeta**:

```dart
// Estás en:
// lib/features/dog_search/presentation/widgets/dog_card.dart

import '../../../../core/utils/image_helper.dart';
//      ↑ widgets
//       ↑ presentation  
//        ↑ dog_search
//         ↑ features
// Ahora estás en lib/ → entras a core/utils/image_helper.dart
```

Cada `../` sube un nivel en la jerarquía de carpetas.

---

## pubspec.yaml — El archivo de configuración del proyecto

```yaml
name: thedogapi        # nombre del paquete
version: 1.0.0+1      # versión (nombre + número de build)

environment:
  sdk: ^3.12.2         # versión mínima de Dart requerida

dependencies:
  flutter:
    sdk: flutter       # el framework Flutter
  http: ^1.6.0         # paquete para hacer peticiones HTTP
  cupertino_icons: ^1.0.8  # íconos estilo iOS

dev_dependencies:
  flutter_test:
    sdk: flutter       # herramientas de testing
  flutter_lints: ^6.0.0   # reglas de buenas prácticas
```

**`^1.6.0`** significa: "versión 1.6.0 o superior, pero no 2.x.x". El símbolo `^` fija el número mayor de versión.

---

## Flujo completo del código — de A a Z

```
1. El usuario abre la app
   main.dart → runApp(TheDogApiApp)

2. Flutter muestra la primera pantalla
   MaterialApp.home → BreedSearchScreen

3. El usuario escribe "Golden" y presiona buscar
   BreedSearchScreen._onSearchSubmitted("Golden")
   → Navigator.push(SearchResultsScreen(initialQuery: "Golden"))

4. Flutter muestra la segunda pantalla
   SearchResultsScreen.initState()
   → _fetchResults()
   → setState(() { _breedsFuture = _apiService.searchBreeds("Golden") })

5. El servicio hace la petición HTTP
   DogApiService.searchBreeds("Golden")
   → GET https://api.thedogapi.com/v1/breeds/search?q=Golden
   → headers: { 'x-api-key': '...' }

6. La API responde con JSON
   [
     { "id": "95", "name": "Golden Retriever", "temperament": "Friendly, ...", ... },
     { "id": "94", "name": "Golden ...", ... }
   ]

7. El servicio parsea el JSON
   DogApiService → jsonList.map((item) => BreedModel.fromJson(item)).toList()
   → [BreedModel(id: "95", name: "Golden Retriever", ...), ...]

8. FutureBuilder recibe los datos y reconstruye la UI
   snapshot.data = [BreedModel, BreedModel, ...]
   → ListView.builder con DogCard por cada raza

9. El usuario toca una tarjeta DogCard
   DogCard.onTap()
   → Navigator.push(DogDetailScreen(breed: BreedModel))

10. La pantalla de detalle carga la imagen adicional
    DogDetailScreen.initState()
    → _loadImageDetails()
    → DogApiService.getImageDetails(breed.referenceImageId)
    → GET https://api.thedogapi.com/v1/images/{id}
    → DogImageModel.fromJson(jsonMap)
    → setState(() { _imageDetail = detail })
```

---

## Beneficios de esta arquitectura

| Beneficio | Cómo lo logra |
|-----------|---------------|
| **Fácil de entender** | Sabes dónde buscar cada cosa (pantalla = screens/, datos = data/) |
| **Fácil de agregar features** | Creas una nueva carpeta en features/ sin tocar lo existente |
| **Fácil de testear** | Puedes probar `DogApiService` sin necesitar la UI |
| **Fácil de mantener** | Si cambia la API, solo tocas `data/` |
| **Reutilizable** | Los widgets de `presentation/widgets/` se usan en varias pantallas |

---

## ¿Y si la app creciera?

Si la app añadiera nuevas funciones, la estructura crecería así:

```
lib/
├── core/                    (igual)
├── features/
│   ├── dog_search/          (lo que ya existe)
│   ├── dog_favorites/       (nueva feature: guardar favoritos)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/ (con base de datos local)
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   └── user_settings/       (otra nueva feature)
│       └── ...
└── main.dart
```

---

*Siguiente: `04_core_constantes_tema_utils.md` — los archivos de la carpeta core/ 🔧*
