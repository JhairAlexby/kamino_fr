import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/1_auth/data/models/auth_response.dart';

void main() {
  test('AuthResponse parsea JSON correctamente', () {
    final json = {
      'user': {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'juan@example.com',
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'role': 'USER',
        'isActive': true,
        'createdAt': '2025-11-13T16:37:03.821Z',
        'updatedAt': '2025-11-13T16:37:03.821Z'
      },
      'accessToken': 'tokenA',
      'refreshToken': 'tokenR'
    };

    final r = AuthResponse.fromJson(json);
    expect(r.user.email, 'juan@example.com');
    expect(r.accessToken, 'tokenA');
    expect(r.refreshToken, 'tokenR');
    expect(r.user.createdAt.isUtc, true);
  });
}
