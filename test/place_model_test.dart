import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';

void main() {
  test('Place parsea JSON y sanea imageUrl', () {
    final json = {
      'id': 'a5c94777-fd2d-474e-aa2b-170dfae09045',
      'name': 'Capilla del Calvario',
      'description': 'Capilla en altura con vistas panorámicas',
      'category': 'Patrimonio Religioso',
      'tags': ['Capilla'],
      'latitude': 16.621,
      'longitude': -93.106,
      'address': 'Suchiapa, Chiapas, México',
      'imageUrl': ' `https://example.com/images/placeholder.jpg` ',
      'isHiddenGem': false,
      'openingTime': null,
      'closingTime': null,
      'tourDuration': null,
      'createdAt': '2025-11-18T04:18:25.719Z',
      'updatedAt': '2025-11-18T04:18:25.719Z',
    };

    final p = Place.fromJson(json);
    expect(p.name, 'Capilla del Calvario');
    expect(p.category, 'Patrimonio Religioso');
    expect(p.tags, ['Capilla']);
    expect(p.latitude, 16.621);
    expect(p.longitude, -93.106);
    expect(p.address, 'Suchiapa, Chiapas, México');
    expect(p.imageUrl, 'https://example.com/images/placeholder.jpg');
    expect(p.isHiddenGem, false);
    expect(p.openingTime, isNull);
    expect(p.closingTime, isNull);
    expect(p.createdAt.isUtc, true);
    expect(p.updatedAt.isUtc, true);
  });
}
