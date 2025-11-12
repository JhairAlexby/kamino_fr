import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';
import 'features/1_auth/presentation/pages/login_page.dart';
import 'features/1_auth/presentation/pages/register_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/welcome_page.dart'; // <-- Importa la nueva
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState(); // instancia compartida
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp.router(
        title: 'Kmino',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(),
        routerDelegate: AppRouterDelegate(appState),
        routeInformationParser: AppRouteInformationParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/welcome'),
        ),
      ),
    );
  }
}