# kamino_fr

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Ejecución con variables de entorno

- Desarrollo:
  - `flutter run --dart-define-from-file=config.dev.json`
- Tests:
  - `flutter test --dart-define-from-file=config.dev.json -r expanded`


## No usar hasta que la app este lista para producción
- Producción (APK):
  - `flutter build apk --dart-define-from-file=config.prod.json`
- Producción (AppBundle):
  - `flutter build appbundle --dart-define-from-file=config.prod.json`
