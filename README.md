# 🐕 Integración con The Dog API para Antigravity

Este documento detalla la arquitectura de integración con [The Dog API](https://thedogapi.com/) para alimentar el flujo de las tres pantallas definidas en los mockups de la aplicación. 

El objetivo es mapear correctamente las peticiones HTTP con los estados de la interfaz, asegurando una experiencia fluida.

## Configuración Inicial y Autenticación

Todas las peticiones a la API requieren autenticación para garantizar límites de uso adecuados.

- **Base URL:** `https://api.thedogapi.com/v1`
- **Header de Autenticación:** 
  ```http
  x-api-key: TU_API_KEY_AQUI
  ```

## Flujo de Pantallas y Endpoints

### Pantalla 1: Vista de Búsqueda
El usuario ingresa un término de búsqueda (ej. "Golden"). Esta vista es el punto de entrada y se enfoca únicamente en capturar el input.

*Nota de implementación:* Se recomienda usar un patrón de *debounce* (retraso intencional) en el campo de texto. Esto evita saturar la API con una petición por cada letra que el usuario teclee.

### Pantalla 2: Resultados de Búsqueda
Presenta los contenedores (cards o grillas) con las coincidencias de razas. 

- **Endpoint:** `GET /breeds/search`
- **Query Parameter:** `q` (el término ingresado en la pantalla 1)

**Ejemplo de Petición:**
```bash
curl -X GET "https://api.thedogapi.com/v1/breeds/search?q=golden"      -H "x-api-key: TU_API_KEY"
```

**Estructura de Respuesta (Resumida):**
```json
[
  {
    "id": 121,
    "name": "Golden Retriever",
    "life_span": "10 - 12 years",
    "temperament": "Intelligent, Kind, Reliable",
    "reference_image_id": "HJ7Pzg5EQ"
  }
]
```

**El desafío del `reference_image_id`:** 
Notarás que este endpoint devuelve metadatos, pero no la URL directa de la imagen para el contenedor. En su lugar, obtienes un `reference_image_id`. Para renderizar los contenedores con foto, puedes armar la URL del CDN estático directamente si conoces la extensión (ej. `https://cdn2.thedogapi.com/images/HJ7Pzg5EQ.jpg`), o alternativamente, hacer la petición de la Pantalla 3 por adelantado (concurrente) para obtener la URL.

### Pantalla 3: Detalle Específico del Perro
Cuando el usuario selecciona un contenedor de la lista, se transita a esta vista mostrando todas las características completas. Utilizaremos el `reference_image_id` obtenido en el paso anterior.

- **Endpoint:** `GET /images/{image_id}`
- **Path Parameter:** El `reference_image_id` del perro seleccionado.

**Ejemplo de Petición:**
```bash
curl -X GET "https://api.thedogapi.com/v1/images/HJ7Pzg5EQ"      -H "x-api-key: TU_API_KEY"
```

**Estructura de Respuesta:**
```json
{
  "id": "HJ7Pzg5EQ",
  "url": "https://cdn2.thedogapi.com/images/HJ7Pzg5EQ.jpg",
  "breeds": [
    {
      "id": 121,
      "name": "Golden Retriever",
      "weight": { "metric": "25 - 34", "imperial": "55 - 75" },
      "height": { "metric": "55 - 61", "imperial": "21.5 - 24" },
      "bred_for": "Retrieving water fowl",
      "breed_group": "Sporting",
      "life_span": "10 - 12 years",
      "temperament": "Intelligent, Kind, Friendly, Confident"
    }
  ],
  "width": 1080,
  "height": 1080
}
```
En este objeto tienes todo lo necesario para pintar la vista de detalle: la URL directa de la imagen de alta resolución, dimensiones, nombre, peso y altura en sistema métrico, origen, grupo, esperanza de vida y temperamento.

## Consideraciones y Edge Cases

Desplegar APIs sin control de estados atípicos es como pasear un Husky sin correa: sabes que eventualmente habrá caos. Considera lo siguiente:

1. **Búsquedas sin resultados:** Si el array de `/breeds/search` retorna vacío `[]`, la UI debe manejar el estado con un componente visual de "No se encontraron razas".
2. **Falta de Imagen (`reference_image_id` nulo):** No todas las razas de la API tienen una foto asociada. Tu modelo de datos debe admitir nulos y la UI debe renderizar un *placeholder* local para evitar excepciones en tiempo de ejecución.
3. **Manejo de Rate Limiting:** Si se alcanza el límite de peticiones (código `429 Too Many Requests`), captura el error y notifica al usuario elegantemente, bloqueando reintentos inmediatos.

---
*Documentación estructurada para integración con el modelo de datos de la aplicación.*
