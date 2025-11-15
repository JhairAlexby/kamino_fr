import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/place.dart';
import '../../data/places_repository.dart';

class NearbyPlacesProvider extends ChangeNotifier {
  final PlacesRepository repository;
  NearbyPlacesProvider({required this.repository});

  List<Place> _places = const [];
  bool _loading = false;
  String? _lastKey;
  Timer? _debounce;
  String? _error;
  bool _useManual = false;
  double _manualRadius = 5.0;
  int _manualLimit = 10;

  List<Place> get places => _places;
  bool get loading => _loading;
  String? get error => _error;
  bool get useManual => _useManual;
  double get manualRadius => _manualRadius;
  int get manualLimit => _manualLimit;

  void disposeDebounce() {
    _debounce?.cancel();
  }

  void loadNearbyDebounced({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
    Duration delay = const Duration(milliseconds: 600),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      _loadNearby(latitude: latitude, longitude: longitude, radius: radius, limit: limit);
    });
  }

  void setManualParams({required bool useManual, required double radius, required int limit}) {
    _useManual = useManual;
    _manualRadius = radius;
    _manualLimit = limit;
    notifyListeners();
  }

  Future<void> _loadNearby({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
  }) async {
    final key = 'lat=$latitude|lng=$longitude|r=$radius|l=$limit';
    if (_lastKey == key && _places.isNotEmpty) return;
    _lastKey = key;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await repository.getNearby(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        limit: limit,
      );
      _places = data;
    } catch (e) {
      _error = 'No se pudieron cargar lugares cercanos';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}