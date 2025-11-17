import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/welcome_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/register_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/login_page.dart';
import 'package:kamino_fr/features/2_home/presentation/pages/home_page.dart';
import 'package:kamino_fr/features/0_splash/presentation/pages/splash_page.dart';

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

GoRouter buildRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: appState,
    redirect: (context, state) {
      final goingHome = state.matchedLocation == '/home';
      if (goingHome && !appState.isAuthenticated) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', name: 'splash', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/welcome', name: 'welcome', builder: (c, s) => const WelcomePage()),
      GoRoute(path: '/register', name: 'register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/home', name: 'home', builder: (c, s) => const HomePage()),
    ],
  );
}
