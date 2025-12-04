## 2025-12-04

- Botón del mapa conectado al flujo de generación de rutas.
- Modal de tiempo funcional y retorno de valor.
- Llamada al backend con ubicación del usuario y minutos disponibles.
- Visualización de rutas devueltas en modal con botón de inicio.
 - Botón "Comenzar ruta" inicia navegación al primer lugar de la ruta y dibuja polilínea en el mapa.
 - Distancias y tiempos corregidos en navegación: Mapbox con tráfico, formato de distancia en km/m y ETA priorizando duración de API.
 - Pruebas añadidas para Haversine (~34 km) y ETA realista.
 - Añadida sección de recomendaciones: carga automática desde backend y renderizado en panel de inicio con estados de carga y error.
 - Pruebas para parseo de recomendaciones y deduplicación en repositorio.
- Etiquetas con el nombre del lugar añadidas junto al ícono de los marcadores del mapa (Mapbox PointAnnotation).
- Corrección: etiquetas visibles aunque falte el asset del ícono, usando el ícono integrado `marker-15`. Se eliminan flags de solapamiento no soportados por `PointAnnotationOptions`.
- Mejora: círculos restaurados y coexistiendo con etiquetas de texto (se crean `CircleAnnotation` y `PointAnnotation` sin ícono por cada lugar).
- Mejora: círculos restaurados y coexistiendo con etiquetas de texto (se crean `CircleAnnotation` y `PointAnnotation` sin ícono por cada lugar). Limpieza de warnings: se elimina `_markerBytes` no usado y se sustituyen colores `.value` por `toARGB32()`.
 - Finalización de rutas: detección automática de llegada con umbral de 25 m y limpieza de polilínea/estado.
 - Botón "Finalizar ruta" en el FAB del mapa, visible solo con ruta activa.
 - Prueba unitaria para `NavigationProvider.hasArrived` y `endRoute` pasando en aislado.
