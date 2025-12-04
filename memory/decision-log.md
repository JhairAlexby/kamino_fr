## 2025-12-04

- Se implementó integración cliente con `POST /api/routes/generate` utilizando `Dio` con inyección de token.
- Se actualizó `GenerationModal` para devolver horas seleccionadas como entero.
- Se añadió `GeneratedRoutesModal` para mostrar las rutas generadas con botón "Comenzar ruta" sin funcionalidad.
- Se documentó el endpoint en `docs/api/routes_generate.md`.
 - Se corrigió cálculo de distancias y ETA: creación de `GeoUtils` con Haversine en metros; `NavigationRepository` ahora usa `driving-traffic` y elimina mocks forzados; fallback calcula distancia y duración por velocidad promedio.
