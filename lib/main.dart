import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';
import 'features/1_auth/presentation/pages/login_page.dart';
import 'features/1_auth/presentation/pages/register_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/welcome_page.dart'; // <-- Importa la nueva
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/1_auth/data/auth_api.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = EnvironmentConfig.load();
  MapboxOptions.setAccessToken(config.mapboxAccessToken);
  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.config});

  final EnvironmentConfig? config;

  @override
  Widget build(BuildContext context) {
    final appState = AppState(); // instancia compartida
    Widget app = MaterialApp.router(
        title: 'Kmino',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(),
        routerDelegate: AppRouterDelegate(appState),
        routeInformationParser: AppRouteInformationParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/welcome'),
        ),
      );

    if (config != null) {
      final storage = SecureTokenStorage();
      final http = HttpClient(config!, storage);
      final authApi = AuthApiImpl(http.dio);
      final repo = AuthRepository(api: authApi, storage: storage);
      app = MultiProvider(
        providers: [
          Provider<EnvironmentConfig>.value(value: config!),
          Provider<AuthRepository>.value(value: repo),
        ],
        child: app,
      );
    }

    return ChangeNotifierProvider.value(
      value: appState,
      child: app,
    );
  }
}
