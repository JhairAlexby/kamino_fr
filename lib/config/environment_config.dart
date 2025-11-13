import 'dart:developer' as dev;

class EnvironmentConfig {
  final String apiBaseUrl;
  final String apiKey;
  final bool enableLogging;
  final int apiTimeout;
  final String environment;
  final bool debugMode;
  final int maxRetries;
  final String mapboxAccessToken;

  EnvironmentConfig._({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.enableLogging,
    required this.apiTimeout,
    required this.environment,
    required this.debugMode,
    required this.maxRetries,
    required this.mapboxAccessToken,
  });

  static EnvironmentConfig load({void Function(String message)? onWarning}) {
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    const key = String.fromEnvironment('API_KEY');
    final _enableLoggingBool = const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: false);
    final _enableLoggingStr = String.fromEnvironment('ENABLE_LOGGING');
    final enableLogging = _enableLoggingStr.isEmpty
        ? _enableLoggingBool
        : _parseBool(_enableLoggingStr, _enableLoggingBool, onWarning);

    final _apiTimeoutInt = const int.fromEnvironment('API_TIMEOUT', defaultValue: 5000);
    final _apiTimeoutStr = String.fromEnvironment('API_TIMEOUT');
    final apiTimeout = _apiTimeoutStr.isEmpty
        ? _apiTimeoutInt
        : _parseInt(_apiTimeoutStr, _apiTimeoutInt, onWarning);
    final environment = String.fromEnvironment('ENVIRONMENT');
    final _debugModeBool = const bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
    final _debugModeStr = String.fromEnvironment('DEBUG_MODE');
    final debugMode = _debugModeStr.isEmpty
        ? _debugModeBool
        : _parseBool(_debugModeStr, _debugModeBool, onWarning);

    final _maxRetriesInt = const int.fromEnvironment('MAX_RETRIES', defaultValue: 3);
    final _maxRetriesStr = String.fromEnvironment('MAX_RETRIES');
    final maxRetries = _maxRetriesStr.isEmpty
        ? _maxRetriesInt
        : _parseInt(_maxRetriesStr, _maxRetriesInt, onWarning);

    const mapboxToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

    _require(baseUrl.isNotEmpty, 'API_BASE_URL');
    _require(key.isNotEmpty, 'API_KEY');
    _require(mapboxToken.isNotEmpty, 'MAPBOX_ACCESS_TOKEN');

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
      mapboxAccessToken: mapboxToken,
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
