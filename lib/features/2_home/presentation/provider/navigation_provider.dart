import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../data/navigation_repository.dart';

class NavigationProvider extends ChangeNotifier {
  final NavigationRepository _repository;
  
  List<Position> _routeCoords = [];
  List<Position> get routeCoords => _routeCoords;
  
  String _etaText = '';
  String get etaText => _etaText;
  
  String _distanceText = '';
  String get distanceText => _distanceText;

  double _totalDistanceMeters = 0;
  double get totalDistanceMeters => _totalDistanceMeters;

  double _totalDurationSeconds = 0;
  double get totalDurationSeconds => _totalDurationSeconds;
  
  // Variable para controlar si se muestra el overlay de "Generando Ruta" (IA)
  bool _isGeneratingRouteOverlay = false;
  bool get isGeneratingRouteOverlay => _isGeneratingRouteOverlay;
  
  // Variable interna para estado de carga general
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _navMode = 'driving';
  String get navMode => _navMode;

  String? _destinationName;
  String? get destinationName => _destinationName;

  NavigationProvider(this._repository);

  Future<void> calculateRoute({
    required double latOrigin,
    required double lonOrigin,
    required double latDest,
    required double lonDest,
    required double currentSpeed,
    String? destinationName,
    bool showOverlay = false,
    String? overrideMode,
  }) async {
    _navMode = overrideMode ?? _detectNavProfile(currentSpeed);
    _isLoading = true;
    if (showOverlay) {
      _isGeneratingRouteOverlay = true;
    }
    _destinationName = destinationName;
    notifyListeners();

    try {
      if (showOverlay) {
        await Future.delayed(const Duration(seconds: 3));
      }
      
      final result = await _repository.getRoute(
        latOrigin: latOrigin,
        lonOrigin: lonOrigin,
        latDest: latDest,
        lonDest: lonDest,
        mode: _navMode,
      );
      _routeCoords = result.coordinates;
      _totalDistanceMeters = result.distanceMeters;
      _totalDurationSeconds = result.durationSeconds;
      
      // Formatear distancia
      if (_totalDistanceMeters >= 1000) {
        _distanceText = '${(_totalDistanceMeters / 1000).toStringAsFixed(1)} km';
      } else {
        _distanceText = '${_totalDistanceMeters.round()} m';
      }

      updateEta(result.distanceMeters, currentSpeed);
    } catch (e) {
      debugPrint("Error calculando ruta: $e");
      _etaText = 'Error';
    } finally {
      _isLoading = false;
      _isGeneratingRouteOverlay = false;
      notifyListeners();
    }
  }

  void updateEta(double distanceMeters, double speed) {
    double sp = speed;
    if (sp.isNaN || sp <= 0) {
      sp = _avgSpeedMetersPerSecond(_navMode);
    }
    if (sp <= 0) {
      _etaText = '';
      notifyListeners();
      return;
    }
    final seconds = (distanceMeters / sp).round();
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final txt = h > 0 ? '${h}h ${m}m' : (m > 0 ? '${m}m ${s}s' : '${s}s');
    
    if (_etaText != txt) {
      _etaText = txt;
      notifyListeners();
    }
  }

  void clearRoute() {
    _routeCoords = [];
    _etaText = '';
    _distanceText = '';
    _destinationName = null;
    notifyListeners();
  }

  // --- Lógica de Negocio Auxiliar ---

  String _detectNavProfile(double speed) {
    final sp = speed.isNaN ? 0.0 : speed;
    if (sp < 2.5) return 'walking';
    if (sp < 7.0) return 'cycling';
    return 'driving';
  }

  double _avgSpeedMetersPerSecond(String mode) {
    switch (mode) {
      case 'walking': return 1.4;
      case 'cycling': return 4.16;
      case 'driving':
      default: return 13.9;
    }
  }

  // --- Lógica Geométrica ---

  double remainingDistanceMeters(double lat, double lon) {
    if (_routeCoords.length < 2) return 0.0;
    int nearestIdx = 0;
    double minD = double.infinity;
    for (int i = 0; i < _routeCoords.length; i++) {
      final d = _haversine(lat, lon, _routeCoords[i].lat.toDouble(), _routeCoords[i].lng.toDouble());
      if (d < minD) { minD = d; nearestIdx = i; }
    }
    double sum = 0.0;
    for (int i = nearestIdx; i < _routeCoords.length - 1; i++) {
      sum += _haversine(
        _routeCoords[i].lat.toDouble(), _routeCoords[i].lng.toDouble(),
        _routeCoords[i + 1].lat.toDouble(), _routeCoords[i + 1].lng.toDouble(),
      );
    }
    return sum;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * (math.sin(dLon / 2) * math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * 0.017453292519943295;
}