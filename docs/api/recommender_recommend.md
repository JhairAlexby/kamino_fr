# GET /api/recommender/recommend

## Descripción
- Devuelve recomendaciones de lugares para el usuario autenticado según la estrategia activa (p. ej., `content_based`).

## Método y Path
- Método: `GET`
- Path: `/api/recommender/recommend`

## Autenticación
- Requiere cabecera `Authorization: Bearer <token>`.
- Requiere cabecera `x-api-key`.

## Parámetros
- No requiere parámetros de consulta.

## Cuerpo de la solicitud
- No aplica.

## Respuestas
- 200 OK
```
{
  "success": true,
  "user_id": "54e0f7c4-bd50-479e-bd29-d7a012f405d6",
  "strategy": "content_based",
  "recommendations": [
    {
      "place_id": "5713633a-5086-4bd3-b5e3-b83c39985e7c",
      "name": "Poza Señor del Pozo",
      "category": "balneario natural",
      "tags": ["naturaleza", "aventura", "familia"],
      "similarity_score": 0.655,
      "final_score": 0.755,
      "is_hidden_gem": true,
      "reason": "Similar a tus lugares favoritos (gema oculta destacada)"
    }
  ]
}
```

- 401 Unauthorized
```
{
  "success": false,
  "error": "invalid_token"
}
```

- 403 Forbidden
```
{
  "success": false,
  "error": "invalid_api_key"
}
```

- 500 Internal Server Error
```
{
  "success": false,
  "error": "server_error"
}
```

## Notas
- El cliente Flutter parsea esta respuesta en `RecommendResponse` y muestra secciones dedicadas en el panel de inicio.
