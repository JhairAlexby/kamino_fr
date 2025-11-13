import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/config/environment_config.dart';

void main() {
  test('Carga dev y tipos', () {
    final cfg = EnvironmentConfig.load();
    expect(cfg.environment, isNotEmpty);
    expect(Uri.parse(cfg.apiBaseUrl).hasScheme, true);
    expect(cfg.enableLogging, isA<bool>());
    expect(cfg.apiTimeout, isA<int>());
    expect(cfg.maxRetries, isA<int>());
    expect(cfg.mapboxAccessToken, isA<String>());
    expect(cfg.mapboxAccessToken.isNotEmpty, true);
  });

  test('Valores esperados dev', () {
    final cfg = EnvironmentConfig.load();
    expect(cfg.environment, 'development');
    expect(cfg.apiTimeout, 5000);
    expect(cfg.maxRetries, 3);
    expect(cfg.enableLogging, true);
    expect(cfg.mapboxAccessToken.isNotEmpty, true);
  });
}
