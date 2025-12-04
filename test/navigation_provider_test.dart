import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/navigation_provider.dart';
import 'package:kamino_fr/features/2_home/data/navigation_repository.dart';

class TestNavigationRepository extends NavigationRepository {
  TestNavigationRepository() : super(Dio(), '');

  @override
  Future<RouteResult> getRoute({
    required double latOrigin,
    required double lonOrigin,
    required double latDest,
    required double lonDest,
    required String mode,
  }) async {
    final coords = <Position>[
      Position(lonOrigin, latOrigin),
      Position((lonOrigin + lonDest) / 2, (latOrigin + latDest) / 2),
      Position(lonDest, latDest),
    ];
    return RouteResult(coordinates: coords, distanceMeters: 100.0, durationSeconds: 60.0);
  }
}

void main() {
  test('hasArrived returns true near destination and endRoute clears state', () async {
    final repo = TestNavigationRepository();
    final provider = NavigationProvider(repo);

    await provider.calculateRoute(
      latOrigin: 0.0,
      lonOrigin: 0.0,
      latDest: 0.0001,
      lonDest: 0.0001,
      currentSpeed: 1.4,
    );

    expect(provider.routeCoords.isNotEmpty, true);

    final arrived = provider.hasArrived(0.0001, 0.0001, thresholdMeters: 30);
    expect(arrived, true);

    provider.endRoute();
    expect(provider.routeCoords.isEmpty, true);
    expect(provider.etaText, '');
    expect(provider.distanceText, '');
  });
}
