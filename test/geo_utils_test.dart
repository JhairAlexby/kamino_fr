import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/core/utils/geo_utils.dart';

void main() {
  test('Haversine calcula ~34 km para latitud separada 0.3°', () {
    final d = GeoUtils.haversineMeters(19.0, -99.0, 19.3, -99.0);
    expect(d, greaterThan(33000));
    expect(d, lessThan(35000));
  });
}

