import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repo;
  final TokenStorage storage;
  final AppState appState;

  bool isLoading = false;
  String? errorMessage;
  bool sessionExpired = false;
  User? user;

  ProfileProvider({required this.repo, required this.storage, required this.appState});

  Future<void> loadProfile() async {
    final token = await storage.getAccessToken();
    if (token == null || token.isEmpty) {
      sessionExpired = true;
      notifyListeners();
      appState.logout();
      appState.setPath(AppRoutePath.login);
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final u = await repo.getProfile();
      user = u;
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code == 401) {
        sessionExpired = true;
        appState.logout();
        appState.setPath(AppRoutePath.login);
      } else {
        errorMessage = 'No se pudo cargar el perfil';
      }
    } catch (_) {
      errorMessage = 'Error inesperado';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadProfile();
  }

  Future<void> copyEmail() async {
    final email = user?.email;
    if (email == null || email.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: email));
  }

  static String translateRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'USER':
        return 'Usuario';
      default:
        return role;
    }
  }

  static String formatDate(DateTime dt) {
    final d = dt.toLocal();
    final two = (int n) => n < 10 ? '0$n' : '$n';
    final day = two(d.day);
    final mon = two(d.month);
    final yr = d.year;
    final h = two(d.hour);
    final m = two(d.minute);
    return '$day/$mon/$yr $h:$m';
  }
}

