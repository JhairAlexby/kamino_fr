import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/navigation_provider.dart';
import 'package:kamino_fr/features/2_home/data/navigation_repository.dart';

class FakeNavigationRepository extends NavigationRepository {
  FakeNavigationRepository() : super(Dio(), '');

  @override
  Future<RouteResult> getRoute({
    required double latOrigin,
    required double lonOrigin,
    required double latDest,
    required double lonDest,
    required String mode,
  }) async {
    return RouteResult(
      coordinates: [
        Position(lonOrigin, latOrigin),
        Position(lonDest, latDest),
      ],
      distanceMeters: 34000.0,
      durationSeconds: 2400.0,
    );
  }
}

void main() {
  test('ETA usa duración de API cuando está disponible', () async {
    final repo = FakeNavigationRepository();
    final vm = NavigationProvider(repo);
    await vm.calculateRoute(
      latOrigin: 19.0,
      lonOrigin: -99.0,
      latDest: 19.3,
      lonDest: -99.0,
      currentSpeed: 0.0,
    );
    expect(vm.etaText.contains('40m'), isTrue);
  });

  test('ETA no muestra 15 min para distancias largas', () {
    final repo = FakeNavigationRepository();
    final vm = NavigationProvider(repo);
    vm.updateEta(100000.0, 13.9);
    final txt = vm.etaText;
    expect(txt.contains('15m'), isFalse);
  });
}

