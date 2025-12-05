import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:kamino_fr/features/3_profile/data/logbook_entry.dart';
import 'package:kamino_fr/features/3_profile/data/logbook_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repo;
  final LogbookRepository logbookRepo;
  final TokenStorage storage;
  final AppState appState;

  // Local storage backup
  final _secureStorage = const FlutterSecureStorage();
  static const _keyLogsBackup = 'logbook_local_backup';

  bool isLoading = false;
  String? errorMessage;
  bool sessionExpired = false;
  User? user;
  
  // Local cache for logs
  List<LogbookEntry> _logs = [];
  List<LogbookEntry> get logs => _logs;

  ProfileProvider({
    required this.repo,
    required this.logbookRepo,
    required this.storage,
    required this.appState,
  });

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
      // Load logs (Hybrid: API preferred, Local fallback)
      await _loadLogs();
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

  Future<void> markAsVisited(String placeId) async {
    if (user == null) return;
    if (isVisited(placeId)) return; // Already visited

    final currentVisited = List<String>.from(user!.visitedPlaces);
    currentVisited.add(placeId);
    user = user!.copyWith(visitedPlaces: currentVisited);
    notifyListeners();

    try {
      await repo.addVisited(placeId);
    } catch (e) {
      // Revert on error
      if (user != null) {
        final reverted = List<String>.from(user!.visitedPlaces);
        reverted.remove(placeId);
        user = user!.copyWith(visitedPlaces: reverted);
        notifyListeners();
      }
    }
  }

  Future<void> toggleVisited(String placeId) async {
    if (user == null) {
      print('ProfileProvider: user is null, cannot toggle visited');
      return;
    }

    final isCurrentlyVisited = isVisited(placeId);
    print('ProfileProvider: toggling visited for $placeId. Current status: $isCurrentlyVisited');
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
        print('ProfileProvider: successfully removed visited $placeId from backend');
      } else {
        await repo.addVisited(placeId);
        print('ProfileProvider: successfully added visited $placeId to backend');
      }
    } catch (e) {
      print('ProfileProvider: error toggling visited: $e');
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

  // Logbook Methods
  Future<void> _loadLogs() async {
    try {
      print('ProfileProvider: Fetching logs from API...');
      final remoteLogs = await logbookRepo.getMyLogs();
      print('ProfileProvider: API returned ${remoteLogs.length} logs');
      
      if (remoteLogs.isNotEmpty) {
        _logs = remoteLogs;
        // Update local backup
        _saveLocalBackup(remoteLogs);
      } else {
        print('ProfileProvider: API returned empty, checking local backup...');
        await _loadLocalBackup();
      }
      notifyListeners();
    } catch (e) {
      print('ProfileProvider: Error fetching remote logs: $e');
      print('ProfileProvider: Falling back to local backup');
      await _loadLocalBackup();
    }
  }

  Future<void> _loadLocalBackup() async {
    try {
      final jsonString = await _secureStorage.read(key: _keyLogsBackup);
      if (jsonString != null) {
        _logs = LogbookEntry.decode(jsonString);
        print('ProfileProvider: Loaded ${_logs.length} logs from local backup');
        notifyListeners();
      }
    } catch (e) {
      print('ProfileProvider: Error loading local backup: $e');
    }
  }

  Future<void> _saveLocalBackup(List<LogbookEntry> logs) async {
    try {
      final jsonString = LogbookEntry.encode(logs);
      await _secureStorage.write(key: _keyLogsBackup, value: jsonString);
    } catch (e) {
      print('ProfileProvider: Error saving local backup: $e');
    }
  }

  Future<void> addLog(LogbookEntry log) async {
    try {
      print('ProfileProvider: Adding log for ${log.placeName}...');
      
      // Optimistic update
      _logs.removeWhere((l) => l.placeId == log.placeId);
      _logs.insert(0, log);
      notifyListeners();
      
      // Save to local backup immediately
      _saveLocalBackup(_logs);

      // Send to API
      print('ProfileProvider: Sending log to API...');
      final created = await logbookRepo.createLog(log);
      print('ProfileProvider: Log saved to API successfully. ID: ${created.id}');
      
      // Update with real ID/data from server
      final index = _logs.indexWhere((l) => l.placeId == log.placeId);
      if (index != -1) {
        _logs[index] = created;
        _saveLocalBackup(_logs); // Update backup with real IDs
        notifyListeners();
      }
    } catch (e) {
      print('ProfileProvider: Error saving log to API: $e');
      // We KEEP the local log so user doesn't lose data, but maybe flag it?
      // For now, just keeping it in local state is better than deleting it.
      errorMessage = 'Error al sincronizar, pero se guardó localmente';
      notifyListeners();
    }
  }

  LogbookEntry? getLogForPlace(String placeId) {
    try {
      return _logs.firstWhere((l) => l.placeId == placeId);
    } catch (_) {
      return null;
    }
  }
}