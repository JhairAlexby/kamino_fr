import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';

void main() {
  test('translateRole traduce roles conocidos', () {
    expect(ProfileProvider.translateRole('USER'), 'Usuario');
    expect(ProfileProvider.translateRole('ADMIN'), 'Administrador');
    expect(ProfileProvider.translateRole('GUEST'), 'GUEST');
  });

  test('formatDate formatea dd/MM/yyyy HH:mm', () {
    final dt = DateTime(2024, 10, 5, 7, 3);
    final s = ProfileProvider.formatDate(dt);
    expect(s, '05/10/2024 07:03');
  });
}

