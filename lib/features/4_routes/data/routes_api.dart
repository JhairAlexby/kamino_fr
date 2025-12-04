import 'package:dio/dio.dart';
import 'models/generated_routes_response.dart';

abstract class RoutesApi {
  Future<GenerateRoutesResponse> generateRoutes({
    required int availableTimeMinutes,
    required double startLatitude,
    required double startLongitude,
    required DateTime startDatetime,
    int maxPlaces = 5,
    int nRoutes = 3,
  });
}

class RoutesApiImpl implements RoutesApi {
  final Dio _dio;
  RoutesApiImpl(this._dio);

  @override
  Future<GenerateRoutesResponse> generateRoutes({
    required int availableTimeMinutes,
    required double startLatitude,
    required double startLongitude,
    required DateTime startDatetime,
    int maxPlaces = 5,
    int nRoutes = 3,
  }) async {
    final body = {
      'available_time_minutes': availableTimeMinutes,
      'start_location': {
        'latitude': startLatitude,
        'longitude': startLongitude,
      },
      'start_datetime': startDatetime.toIso8601String(),
      'max_places': maxPlaces,
      'n_routes': nRoutes,
    };
    final res = await _dio.post('/api/routes/generate', data: body);
    final data = res.data as Map<String, dynamic>;
    return GenerateRoutesResponse.fromJson(data);
  }
}

