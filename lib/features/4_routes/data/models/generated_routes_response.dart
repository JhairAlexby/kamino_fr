class GeneratedPlace {
  final String placeId;
  final String name;
  final String category;
  final List<String> tags;
  final int order;
  final int visitDurationMinutes;
  final int travelTimeFromPrevious;
  final String arrivalTime;
  final String departureTime;
  final double latitude;
  final double longitude;

  GeneratedPlace({
    required this.placeId,
    required this.name,
    required this.category,
    required this.tags,
    required this.order,
    required this.visitDurationMinutes,
    required this.travelTimeFromPrevious,
    required this.arrivalTime,
    required this.departureTime,
    required this.latitude,
    required this.longitude,
  });

  factory GeneratedPlace.fromJson(Map<String, dynamic> json) {
    return GeneratedPlace(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      order: (json['order'] as num).toInt(),
      visitDurationMinutes: (json['visit_duration_minutes'] as num).toInt(),
      travelTimeFromPrevious: (json['travel_time_from_previous'] as num).toInt(),
      arrivalTime: json['arrival_time'] as String,
      departureTime: json['departure_time'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class GeneratedRoute {
  final int routeId;
  final int totalDurationMinutes;
  final double totalDistanceKm;
  final int numberOfPlaces;
  final List<GeneratedPlace> places;
  final double fitnessScore;

  GeneratedRoute({
    required this.routeId,
    required this.totalDurationMinutes,
    required this.totalDistanceKm,
    required this.numberOfPlaces,
    required this.places,
    required this.fitnessScore,
  });

  factory GeneratedRoute.fromJson(Map<String, dynamic> json) {
    final rawPlaces = json['places'] as List? ?? const [];
    return GeneratedRoute(
      routeId: (json['route_id'] as num).toInt(),
      totalDurationMinutes: (json['total_duration_minutes'] as num).toInt(),
      totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
      numberOfPlaces: (json['number_of_places'] as num).toInt(),
      places: rawPlaces.map((e) => GeneratedPlace.fromJson(e as Map<String, dynamic>)).toList(),
      fitnessScore: (json['fitness_score'] as num).toDouble(),
    );
  }
}

class GenerateRoutesResponse {
  final bool success;
  final String userId;
  final int availableTimeMinutes;
  final List<GeneratedRoute> routes;

  GenerateRoutesResponse({
    required this.success,
    required this.userId,
    required this.availableTimeMinutes,
    required this.routes,
  });

  factory GenerateRoutesResponse.fromJson(Map<String, dynamic> json) {
    final rawRoutes = json['routes'] as List? ?? const [];
    return GenerateRoutesResponse(
      success: json['success'] as bool? ?? false,
      userId: json['user_id'] as String? ?? '',
      availableTimeMinutes: (json['available_time_minutes'] as num?)?.toInt() ?? 0,
      routes: rawRoutes.map((e) => GeneratedRoute.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

