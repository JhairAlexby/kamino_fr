import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/welcome_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/register_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/login_page.dart';
import 'package:kamino_fr/features/2_home/presentation/pages/home_page.dart';

class AppRoutePath {
  final String location;
  const AppRoutePath(this.location);

  static const welcome = AppRoutePath('/welcome');
  static const register = AppRoutePath('/register');
  static const login = AppRoutePath('/login');
  static const home = AppRoutePath('/home');

  bool get isWelcome => location == '/welcome';
  bool get isRegister => location == '/register';
  bool get isLogin => location == '/login';
  bool get isHome => location == '/home';
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    // Si no viene location, asumimos /welcome
    final loc = routeInformation.location ?? '/welcome';
    final uri = Uri.parse(loc);
    final first = '/${uri.pathSegments.isEmpty ? '' : uri.pathSegments.first}';
    switch (first) {
      case '/register':
        return AppRoutePath.register;
      case '/login':
        return AppRoutePath.login;
      case '/home':
        return AppRoutePath.home;
      case '/':
        return AppRoutePath.welcome;
      case '/welcome':
      default:
        return AppRoutePath.welcome;
    }
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}

class AppState extends ChangeNotifier {
  AppRoutePath _current = AppRoutePath.welcome;
  AppRoutePath get currentPath => _current;

  void setPath(AppRoutePath path) {
    _current = path;
    notifyListeners();
  }
}

// Clase: AppRouterDelegate
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  AppRouterDelegate(this.appState) {
    appState.addListener(notifyListeners);
  }

  final AppState appState;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath? get currentConfiguration => appState.currentPath;

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    appState.setPath(configuration);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Page>[];

    if (appState.currentPath.isWelcome) {
      pages.add(
        MaterialPage(
          key: const ValueKey('WelcomePage'),
          child: const WelcomePage(),
        ),
      );
    } else if (appState.currentPath.isRegister) {
      pages.add(
        MaterialPage(
          key: const ValueKey('WelcomePage'),
          child: const WelcomePage(),
        ),
      );
      pages.add(
        MaterialPage(
          key: const ValueKey('RegisterPage'),
          child: const RegisterPage(),
        ),
      );
    } else if (appState.currentPath.isLogin) {
      pages.add(
        MaterialPage(
          key: const ValueKey('WelcomePage'),
          child: const WelcomePage(),
        ),
      );
      pages.add(
        MaterialPage(
          key: const ValueKey('LoginPage'),
          child: const LoginPage(),
        ),
      );
    } else if (appState.currentPath.isHome) {
      pages.add(
        MaterialPage(
          key: const ValueKey('HomePage'),
          child: const HomePage(),
        ),
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        // Al hacer pop, si estamos en Register/Login volvemos a Welcome.
        // Si estamos en Home, no hay página debajo.
        if (!appState.currentPath.isHome) {
          appState.setPath(AppRoutePath.welcome);
        }
        return true;
      },
    );
  }
}