import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/welcome_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/register_page.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/login_page.dart';
import 'package:kamino_fr/features/1_auth/presentation/pages/complete_profile_page.dart';
import 'package:kamino_fr/features/2_home/presentation/pages/home_page.dart';
import 'package:kamino_fr/features/0_splash/presentation/pages/splash_page.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AppState extends ChangeNotifier {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  AuthStatus _status = AuthStatus.unknown;
  bool _profileComplete = false;
  AuthStatus get status => _status;
  bool get profileComplete => _profileComplete;
  AppState(this.authRepository, this.profileRepository) {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    final token = await authRepository.checkAuthStatus();
    _status = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (_status == AuthStatus.authenticated) {
      try {
        final u = await profileRepository.getProfile();
        _profileComplete = (u.gender != null && u.gender!.isNotEmpty) && (u.preferredTags.isNotEmpty);
      } catch (_) {
        _profileComplete = false;
      }
    } else {
      _profileComplete = false;
    }
    notifyListeners();
  }

  void markProfileComplete() {
    _profileComplete = true;
    notifyListeners();
  }

  void login() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await authRepository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

GoRouter buildRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: appState,
    redirect: (context, state) {
      final currentStatus = appState.status;
      final onSplash = state.matchedLocation == '/splash';

      if (currentStatus == AuthStatus.unknown) {
        return onSplash ? null : '/splash';
      }

      final onAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/welcome';

      if (currentStatus == AuthStatus.authenticated) {
        if (!appState.profileComplete && state.matchedLocation != '/complete-profile') {
          return '/complete-profile';
        }
        if (appState.profileComplete && (onAuthRoute || onSplash)) return '/home';
      } else {
        if (!onAuthRoute && !onSplash) return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', name: 'splash', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/welcome', name: 'welcome', builder: (c, s) => const WelcomePage()),
      GoRoute(path: '/register', name: 'register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/complete-profile', name: 'complete_profile', builder: (c, s) => const CompleteProfilePage()),
      GoRoute(path: '/home', name: 'home', builder: (c, s) => const HomePage()),
    ],
  );
}