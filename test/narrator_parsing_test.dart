import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/2_home/data/narrator_api.dart';

void main() {
  test('parseNarratorText extrae data.text correctamente', () {
    final json = {
      'success': true,
      'statusCode': 200,
      'message': 'Datos obtenidos exitosamente',
      'data': {
        'text': 'Desde su inauguración en 2012, el Museo Chiapas...'
      },
      'timestamp': '2025-12-04T00:45:09.905Z'
    };
    final text = parseNarratorText(json);
    expect(text, isNotNull);
    expect(text, contains('Museo Chiapas'));
  });

  test('parseNarratorText retorna null si no hay texto', () {
    final json = {
      'success': true,
      'statusCode': 200,
      'message': 'Datos obtenidos exitosamente',
      'data': {
        'text': ''
      },
      'timestamp': '2025-12-04T00:45:09.905Z'
    };
    final text = parseNarratorText(json);
    expect(text, isNull);
  });
}
