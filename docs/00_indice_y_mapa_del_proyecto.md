# 🗺️ Índice y Mapa del Proyecto — TheDogAPI Explorer

> **¿Cero conocimiento de Flutter/Dart? ¡Perfecto! Esta guía está hecha exactamente para ti.**
> Lee los archivos en orden numérico y en menos de un día entenderás TODO el proyecto.

---

## 📚 Orden de lectura recomendado

| # | Archivo | Qué aprenderás | Tiempo estimado |
|---|---------|----------------|-----------------|
| 00 | **Este archivo** | Mapa general del proyecto | 5 min |
| 01 | `01_dart_desde_cero.md` | Lenguaje Dart completo (tipos, funciones, clases, async) | 30 min |
| 02 | `02_flutter_desde_cero.md` | Flutter: widgets, estado, navegación, layouts | 40 min |
| 03 | `03_arquitectura_y_estructura.md` | Cómo está organizado el proyecto y por qué | 20 min |
| 04 | `04_core_constantes_tema_utils.md` | La capa `core/`: AppTheme, ApiConstants, ImageHelper | 20 min |
| 05 | `05_modelos_de_datos.md` | BreedModel, DogImageModel, JSON y `fromJson` | 25 min |
| 06 | `06_servicio_api_http.md` | DogApiService: HTTP, Future, manejo de errores | 30 min |
| 07 | `07_pantalla1_busqueda.md` | BreedSearchScreen: StatefulWidget, TextField, Navigator | 30 min |
| 08 | `08_pantalla2_resultados.md` | SearchResultsScreen: FutureBuilder, ListView, estados | 30 min |
| 09 | `09_pantalla3_detalle.md` | DogDetailScreen: SliverAppBar, widgets auxiliares | 30 min |
| 10 | `10_widgets_reutilizables.md` | DogCard, EmptyState, ErrorState — componentes reusables | 20 min |

**Total estimado: ~4 horas de lectura activa con código.**

---

## 🗂️ Mapa visual del proyecto

```
TheDogAPI.flutter/
│
├── lib/                          ← TODO el código Dart/Flutter vive aquí
│   ├── main.dart                 ← Punto de entrada (el "arranque" de la app)
│   │
│   ├── core/                     ← Cosas compartidas por toda la app
│   │   ├── constants/
│   │   │   └── api_constants.dart    ← URLs y headers de la API
│   │   ├── theme/
│   │   │   └── app_theme.dart        ← Colores, fuentes, estilos globales
│   │   └── utils/
│   │       └── image_helper.dart     ← Helper para imágenes en Web (CORS)
│   │
│   └── features/                 ← Features = funcionalidades de la app
│       └── dog_search/           ← Feature: buscar razas de perros
│           ├── data/             ← Capa de datos (API + modelos)
│           │   ├── models/
│           │   │   ├── breed_model.dart       ← Clase que representa una Raza
│           │   │   └── dog_image_model.dart   ← Clase que representa una Imagen
│           │   └── services/
│           │       └── dog_api_service.dart   ← Hace las llamadas HTTP a la API
│           │
│           └── presentation/     ← Capa de UI (lo que el usuario ve)
│               ├── screens/
│               │   ├── breed_search_screen.dart   ← Pantalla 1: Búsqueda
│               │   ├── search_results_screen.dart ← Pantalla 2: Resultados
│               │   └── dog_detail_screen.dart     ← Pantalla 3: Detalle del perro
│               └── widgets/
│                   ├── dog_card.dart              ← Tarjeta de raza en la lista
│                   ├── empty_state_widget.dart    ← "No se encontraron resultados"
│                   └── error_state_widget.dart    ← "Ocurrió un error"
│
├── pubspec.yaml                  ← Dependencias del proyecto (como package.json)
└── docs/                         ← ← ← ESTÁS AQUÍ — Documentación de estudio
```

---

## 🔄 Flujo de la aplicación

```
Usuario abre la app
       ↓
main.dart → runApp(TheDogApiApp)
       ↓
MaterialApp → home: BreedSearchScreen()
       ↓ (usuario escribe y busca)
Navigator.push → SearchResultsScreen(query: "Golden")
       ↓ (llama a la API)
DogApiService.searchBreeds("Golden")
       → GET https://api.thedogapi.com/v1/breeds/search?q=Golden
       ← [{ id, name, temperament, ... }, ...]
       ↓
FutureBuilder → muestra lista de DogCard
       ↓ (usuario toca una tarjeta)
Navigator.push → DogDetailScreen(breed: BreedModel)
       ↓ (carga imagen extra)
DogApiService.getImageDetails(referenceImageId)
       → GET https://api.thedogapi.com/v1/images/{id}
       ← { id, url, width, height, breeds: [...] }
       ↓
Pantalla de detalle completa con foto, stats y temperamento
```

---

## 🧩 Las 3 pantallas de la app

### Pantalla 1 — Búsqueda (`BreedSearchScreen`)
- Header con logo e ícono
- Banner hero naranja con descripción
- Campo de texto para buscar
- Botón de búsqueda
- Chips de búsquedas rápidas populares (Terrier, Golden, Bulldog...)
- Nota informativa sobre la API

### Pantalla 2 — Resultados (`SearchResultsScreen`)
- Barra de búsqueda refinable
- Indicador de carga (`CircularProgressIndicator`)
- Contador de resultados encontrados
- Lista de tarjetas `DogCard` (una por raza)
- Estado vacío si no hay resultados
- Estado de error si falla la API

### Pantalla 3 — Detalle (`DogDetailScreen`)
- Header colapsable con foto de la raza
- Botón para ver foto en pantalla completa con zoom
- Cards de métricas: Peso, Altura, Vida, Grupo
- Tags de temperamento y personalidad
- Secciones: Origen, Para qué fue criado, Descripción, Historia
- Info técnica de la API

---

## 📦 Dependencias externas usadas

| Paquete | Para qué sirve |
|---------|----------------|
| `flutter` | El SDK principal — widgets, material design, etc. |
| `http` | Para hacer peticiones HTTP a TheDogAPI |
| `cupertino_icons` | Íconos estilo iOS (Apple) |

---

## 🌐 API que consume la app

**TheDogAPI** — `https://api.thedogapi.com/v1`

| Endpoint | Método | Para qué |
|----------|--------|----------|
| `/breeds/search?q={query}` | GET | Buscar razas por nombre |
| `/images/{image_id}` | GET | Obtener detalle de imagen de una raza |

- La API requiere un API Key en el header: `x-api-key`
- Se configura con `--dart-define=DOG_API_KEY=tu_llave` al compilar
- Las imágenes vienen del CDN: `https://cdn2.thedogapi.com/images/{id}.jpg`

---

## 💡 Conceptos clave de Flutter que aprenderás

1. **Widget** — Todo en Flutter es un widget (bloque visual)
2. **StatelessWidget vs StatefulWidget** — Sin estado vs con estado
3. **setState()** — Cómo actualizar la UI
4. **Future y async/await** — Programación asíncrona
5. **FutureBuilder** — Widget que reacciona a Futures
6. **Navigator** — Sistema de navegación entre pantallas
7. **Scaffold** — Estructura base de una pantalla
8. **Column, Row, Stack** — Layouts básicos
9. **ListView.builder** — Lista de elementos eficiente
10. **ThemeData** — Estilos globales de la app

---

*Empieza por `01_dart_desde_cero.md` → ¡vamos! 🚀*
