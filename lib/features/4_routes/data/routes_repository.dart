import 'routes_api.dart';
import 'models/generated_routes_response.dart';

class RoutesRepository {
  final RoutesApi api;
  RoutesRepository({required this.api});

  Future<GenerateRoutesResponse> generate({
    required int availableTimeMinutes,
    required double startLatitude,
    required double startLongitude,
    required DateTime startDatetime,
    int maxPlaces = 5,
    int nRoutes = 3,
  }) {
    return api.generateRoutes(
      availableTimeMinutes: availableTimeMinutes,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      startDatetime: startDatetime,
      maxPlaces: maxPlaces,
      nRoutes: nRoutes,
    );
  }
}

