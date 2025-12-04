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
      await storage.clearTokens();
      appState.logout();
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
        await storage.clearTokens();
        appState.logout();
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

  Future<void> updateProfileData({
    required String firstName,
    required String lastName,
    required List<String> tags,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repo.updateProfile(firstName: firstName, lastName: lastName);
      await repo.updateTags(tags);
      // Recargamos el perfil para asegurar que tenemos la data más fresca
      await loadProfile();
    } catch (e) {
      errorMessage = 'Error al actualizar los datos';
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool isLiked(String placeId) {
    return user?.favoritePlaces.contains(placeId) ?? false;
  }

  Future<void> toggleFavorite(String placeId) async {
    if (user == null) return;

    final isCurrentlyLiked = isLiked(placeId);
    final currentFavorites = List<String>.from(user!.favoritePlaces);

    // Optimistic update
    if (isCurrentlyLiked) {
      currentFavorites.remove(placeId);
    } else {
      currentFavorites.add(placeId);
    }

    user = user!.copyWith(favoritePlaces: currentFavorites);
    notifyListeners();

    try {
      if (isCurrentlyLiked) {
        await repo.removeFavorite(placeId);
      } else {
        await repo.addFavorite(placeId);
      }
    } catch (e) {
      // Revert on error
      final revertedFavorites = List<String>.from(user!.favoritePlaces);
      if (isCurrentlyLiked) {
        revertedFavorites.add(placeId);
      } else {
        revertedFavorites.remove(placeId);
      }
      user = user!.copyWith(favoritePlaces: revertedFavorites);
      notifyListeners();
      // Don't rethrow to avoid UI crash, just show error message if needed
      errorMessage = 'Error al actualizar favoritos';
      notifyListeners();
    }
  }

  bool isVisited(String placeId) {
    return user?.visitedPlaces.contains(placeId) ?? false;
  }

  Future<void> toggleVisited(String placeId) async {
    if (user == null) return;

    final isCurrentlyVisited = isVisited(placeId);
    final currentVisited = List<String>.from(user!.visitedPlaces);

    // Optimistic update
    if (isCurrentlyVisited) {
      currentVisited.remove(placeId);
    } else {
      currentVisited.add(placeId);
    }

    user = user!.copyWith(visitedPlaces: currentVisited);
    notifyListeners();

    try {
      if (isCurrentlyVisited) {
        await repo.removeVisited(placeId);
      } else {
        await repo.addVisited(placeId);
      }
    } catch (e) {
      // Revert on error
      final revertedVisited = List<String>.from(user!.visitedPlaces);
      if (isCurrentlyVisited) {
        revertedVisited.add(placeId);
      } else {
        revertedVisited.remove(placeId);
      }
      user = user!.copyWith(visitedPlaces: revertedVisited);
      notifyListeners();
      errorMessage = 'Error al actualizar visitados';
      notifyListeners();
    }
  }
}