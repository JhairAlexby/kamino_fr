import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/4_routes/data/models/generated_routes_response.dart';

void main() {
  test('parse generated routes response', () {
    final json = {
      "success": true,
      "user_id": "54e0f7c4-bd50-479e-bd29-d7a012f405d6",
      "available_time_minutes": 140,
      "routes": [
        {
          "route_id": 3,
          "total_duration_minutes": 135,
          "total_distance_km": 1.66,
          "number_of_places": 3,
          "places": [
            {
              "place_id": "609c2b09-eb6f-489f-8769-f8e49c9bf894",
              "name": "Café San Carlos",
              "category": "cafe",
              "tags": ["gastronomía", "tradicional", "familia"],
              "order": 1,
              "visit_duration_minutes": 45,
              "travel_time_from_previous": 5,
              "arrival_time": "09:05",
              "departure_time": "09:50",
              "latitude": 16.757,
              "longitude": -93.128
            }
          ],
          "fitness_score": 0.773
        }
      ]
    };

    final res = GenerateRoutesResponse.fromJson(json);
    expect(res.success, true);
    expect(res.userId, '54e0f7c4-bd50-479e-bd29-d7a012f405d6');
    expect(res.availableTimeMinutes, 140);
    expect(res.routes.length, 1);
    final route = res.routes.first;
    expect(route.totalDurationMinutes, 135);
    expect(route.totalDistanceKm, 1.66);
    expect(route.numberOfPlaces, 3);
    expect(route.places.length, 1);
    final place = route.places.first;
    expect(place.name, 'Café San Carlos');
    expect(place.order, 1);
    expect(place.visitDurationMinutes, 45);
    expect(place.arrivalTime, '09:05');
  });
}

