import 'package:dio/dio.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RouteResult {
  final List<Position> coordinates;
  final double distanceMeters;
  final double durationSeconds;

  RouteResult({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class NavigationRepository {
  final Dio _dio;
  final String _accessToken;

  NavigationRepository(this._dio, this._accessToken);

  Future<RouteResult> getRoute({
    required double latOrigin,
    required double lonOrigin,
    required double latDest,
    required double lonDest,
    required String mode,
  }) async {
    // Construimos la URL de la API de Directions de Mapbox
    final url = 'https://api.mapbox.com/directions/v5/mapbox/$mode/$lonOrigin,$latOrigin;$lonDest,$latDest?geometries=geojson&access_token=$_accessToken';
    
    try {
      final resp = await _dio.get(url);
      final data = resp.data as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? [];

      if (routes.isEmpty) {
        throw Exception('No se encontró una ruta');
      }

      final r0 = routes.first as Map<String, dynamic>;
      final geometry = r0['geometry'] as Map<String, dynamic>;
      final coords = (geometry['coordinates'] as List).cast<List>();
      
      // Convertimos las coordenadas crudas a objetos Position
      final points = coords.map((c) => Position((c[0] as num).toDouble(), (c[1] as num).toDouble())).toList();
      final distance = (r0['distance'] as num?)?.toDouble() ?? 0.0;
      final duration = (r0['duration'] as num?)?.toDouble() ?? 0.0;

      return RouteResult(
        coordinates: points,
        distanceMeters: distance,
        durationSeconds: duration,
      );
    } catch (e) {
      // Aquí podrías manejar errores específicos de Dio o Mapbox
      rethrow;
    }
  }
}