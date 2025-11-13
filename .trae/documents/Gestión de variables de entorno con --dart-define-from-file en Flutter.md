# Objetivo

Implementar gestión de variables en tiempo de compilación con `--dart-define-from-file`, asegurando seguridad, escalabilidad y mantenimiento en el proyecto Flutter detectado.

## Archivos de configuración

* Crear en la raíz `config.dev.json` y `config.prod.json` con valores en formato **string** (requisito de `--dart-define-from-file`).

* Contenido recomendado:

```json
{
  "API_BASE_URL": "https://api-dev.example.com",
  "API_KEY": "dev_api_key_here",
  "ENABLE_LOGGING": "true",
  "API_TIMEOUT": "5000",
  "ENVIRONMENT": "development",
  "DEBUG_MODE": "true",
  "MAX_RETRIES": "3"
}
```

```json
{
  "API_BASE_URL": "https://api.example.com",
  "API_KEY": "prod_api_key_here",
  "ENABLE_LOGGING": "false",
  "API_TIMEOUT": "10000",
  "ENVIRONMENT": "production",
  "DEBUG_MODE": "false",
  "MAX_RETRIES": "5"
}
```

* Crear plantillas versionadas: `config.dev.template.json` y `config.prod.template.json` (sin secretos), por ejemplo:

```json
{
  "API_BASE_URL": "https://<dev-host>",
  "API_KEY": "CHANGE_ME",
  "ENABLE_LOGGING": "true",
  "API_TIMEOUT": "5000",
  "ENVIRONMENT": "development",
  "DEBUG_MODE": "true",
  "MAX_RETRIES": "3"
}
```

```json
{
  "API_BASE_URL": "https://<prod-host>",
  "API_KEY": "CHANGE_ME",
  "ENABLE_LOGGING": "false",
  "API_TIMEOUT": "10000",
  "ENVIRONMENT": "production",
  "DEBUG_MODE": "false",
  "MAX_RETRIES": "5"
}
```

## Seguridad y versionado

* Añadir patrones al `.gitignore` para evitar versionar credenciales:

```
config.*.json
!config.dev.template.json
!config.prod.template.json
```

* Mantener secretos fuera del repo; compartir `*.template.json` como documentación viva.

* En CI/CD, inyectar archivos reales desde secretos del sistema (por ejemplo, GitHub Actions `secrets` + artifact/checkout temporal).

## Comandos Flutter

* Desarrollo: `flutter run --dart-define-from-file=config.dev.json`

* Producción (APK): `flutter build apk --dart-define-from-file=config.prod.json`

* Producción (AppBundle): `flutter build appbundle --dart-define-from-file=config.prod.json`

* Web: `flutter build web --dart-define-from-file=config.prod.json`

* Tests: `flutter test --dart-define-from-file=config.dev.json`

## Implementación en código

* Crear `lib/config/environment_config.dart` con carga, parseo, validación y avisos cuando se apliquen valores por defecto.

```dart
import 'dart:developer' as dev;

class EnvironmentConfig {
  final String apiBaseUrl;
  final String apiKey;
  final bool enableLogging;
  final int apiTimeout;
  final String environment;
  final bool debugMode;
  final int maxRetries;

  EnvironmentConfig._({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.enableLogging,
    required this.apiTimeout,
    required this.environment,
    required this.debugMode,
    required this.maxRetries,
  });

  static EnvironmentConfig load({void Function(String message)? onWarning}) {
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    const key = String.fromEnvironment('API_KEY');
    final enableLogging = _parseBool(String.fromEnvironment('ENABLE_LOGGING'), false, onWarning);
    final apiTimeout = _parseInt(String.fromEnvironment('API_TIMEOUT'), 5000, onWarning);
    final environment = String.fromEnvironment('ENVIRONMENT');
    final debugMode = _parseBool(String.fromEnvironment('DEBUG_MODE'), false, onWarning);
    final maxRetries = _parseInt(String.fromEnvironment('MAX_RETRIES'), 3, onWarning);

    _require(baseUrl.isNotEmpty, 'API_BASE_URL');
    _require(key.isNotEmpty, 'API_KEY');

    _validateUrl(baseUrl);
    _validateRange(apiTimeout > 0 && apiTimeout <= 60000, 'API_TIMEOUT');
    _validateRange(maxRetries >= 0 && maxRetries <= 10, 'MAX_RETRIES');

    return EnvironmentConfig._(
      apiBaseUrl: baseUrl,
      apiKey: key,
      enableLogging: enableLogging,
      apiTimeout: apiTimeout,
      environment: environment.isNotEmpty ? environment : 'development',
      debugMode: debugMode,
      maxRetries: maxRetries,
    );
  }

  static bool _parseBool(String value, bool fallback, void Function(String message)? onWarning) {
    if (value.isEmpty) { _warn('ENABLE_LOGGING default=$fallback', onWarning); return fallback; }
    final v = value.toLowerCase();
    if (v == 'true') return true;
    if (v == 'false') return false;
    _warn('Boolean parse error value="$value" default=$fallback', onWarning);
    return fallback;
  }

  static int _parseInt(String value, int fallback, void Function(String message)? onWarning) {
    if (value.isEmpty) { _warn('Default int applied value=$fallback', onWarning); return fallback; }
    final parsed = int.tryParse(value);
    if (parsed == null) { _warn('Int parse error value="$value" default=$fallback', onWarning); return fallback; }
    return parsed;
  }

  static void _require(bool condition, String name) {
    if (!condition) { throw StateError('Missing required variable $name'); }
  }

  static void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    final ok = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    if (!ok) { throw StateError('Invalid API_BASE_URL="$url"'); }
  }

  static void _validateRange(bool ok, String name) {
    if (!ok) { throw StateError('Invalid range for $name'); }
  }

  static void _warn(String message, void Function(String message)? onWarning) {
    if (onWarning != null) { onWarning(message); } else { dev.log(message, level: 900); }
  }
}
```

* Integración en `lib/main.dart` al inicio:

```dart
import 'config/environment_config.dart';

void main() {
  final config = EnvironmentConfig.load();
  runApp(MyApp(config: config));
}
```

* Usar `config` donde se construyan clientes HTTP, timeouts y flags de logging.

## Validación (tests)

* Añadir `test/environment_config_test.dart` con pruebas de carga, defaults y formato/tipo.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project/config/environment_config.dart';

void main() {
  test('Carga dev', () {
    final cfg = EnvironmentConfig.load();
    expect(cfg.environment, 'development');
    expect(cfg.apiBaseUrl, isNotEmpty);
    expect(cfg.enableLogging, isTrue);
    expect(cfg.apiTimeout, 5000);
  });

  test('Formato URL válido', () {
    final cfg = EnvironmentConfig.load();
    expect(Uri.parse(cfg.apiBaseUrl).host, isNotEmpty);
  });
}
```

* Ejecutar: `flutter test --dart-define-from-file=config.dev.json`.

* Para validar errores por ausencia de obligatorias, ejecutar suite separada con un archivo de pruebas (p.ej. `config.dev.missing.json` sin `API_KEY`), y esperar `StateError`:

```bash
flutter test --dart-define-from-file=config.dev.missing.json -t missing_required
```

## Buenas prácticas 2025

* Mantener todas las claves en un único punto (`EnvironmentConfig`) y documentarlas en las plantillas.

* Evitar booleans/números sin comillas en JSON; parsear explícitamente como se muestra.

* Limitar rangos y validar formatos para evitar builds inválidos.

* En producción, no revelar secretos críticos en el binario; usar backend y tokens de corta vida.

* Automatizar en CI la verificación de presencia de archivos de entorno antes de build.

## Cambios previstos en el repo

1. Añadir `config.dev.json`, `config.prod.json` y sus plantillas.
2. Actualizar `.gitignore` con patrones propuestos.
3. Crear `lib/config/environment_config.dart`.
4. Integrar la carga en `lib/main.dart`.
5. Añadir `test/environment_config_test.dart` y comandos de test.

Si apruebas el plan, procedo a realizar los cambios y a verificar con tests y builds de ejemplo.

recuerda mantener el estandar de la arquitectura limpia
