# POST `/api/routes/generate`

- Método: `POST`
- Descripción: Genera rutas personalizadas en función del tiempo disponible del usuario y su ubicación de inicio.
- Autenticación: `Authorization: Bearer <token>` requerida.

## Parámetros
- `available_time_minutes` (`number`, requerido): Minutos disponibles para la ruta.
- `start_location` (`object`, requerido): Coordenadas iniciales.
  - `latitude` (`number`, requerido)
  - `longitude` (`number`, requerido)
- `start_datetime` (`string`, requerido): Fecha/hora ISO 8601 del inicio.
- `max_places` (`number`, opcional): Máximo de lugares por ruta. Por defecto `5`.
- `n_routes` (`number`, opcional): Número de rutas a generar. Por defecto `3`.

## Request Body (ejemplo)
```json
{
  "available_time_minutes": 240,
  "start_location": {
    "latitude": 16.7536,
    "longitude": -93.1233
  },
  "start_datetime": "2025-12-01T09:00:00",
  "max_places": 5,
  "n_routes": 3
}
```

## Respuestas
- `200 OK`
  ```json
  {
    "success": true,
    "user_id": "54e0f7c4-bd50-479e-bd29-d7a012f405d6",
    "available_time_minutes": 140,
    "routes": [
      {
        "route_id": 3,
        "total_duration_minutes": 135,
        "total_distance_km": 1.66,
        "number_of_places": 3,
        "places": [
          {
            "place_id": "609c2b09-eb6f-489f-8769-f8e49c9bf894",
            "name": "Café San Carlos",
            "category": "cafe",
            "tags": ["gastronomía", "tradicional", "familia"],
            "order": 1,
            "visit_duration_minutes": 45,
            "travel_time_from_previous": 5,
            "arrival_time": "09:05",
            "departure_time": "09:50",
            "latitude": 16.757,
            "longitude": -93.128
          }
        ],
        "fitness_score": 0.773
      }
    ]
  }
  ```
- `400 Bad Request`
  ```json
  { "message": "Parámetros inválidos" }
  ```
- `401 Unauthorized`
  ```json
  { "message": "Token inválido o faltante" }
  ```
- `500 Internal Server Error`
  ```json
  { "message": "Error interno" }
  ```

