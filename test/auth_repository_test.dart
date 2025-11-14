import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/features/1_auth/data/auth_api.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/1_auth/data/models/auth_response.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';

class _FakeAuthApi implements AuthApi {
  @override
  Future<AuthResponse> login({required String email, required String password}) async {
    return AuthResponse(
      user: User(
        id: 'id',
        email: email,
        firstName: 'Juan',
        lastName: 'Pérez',
        role: 'USER',
        isActive: true,
        createdAt: DateTime.parse('2025-11-13T16:37:03.821Z'),
        updatedAt: DateTime.parse('2025-11-13T16:37:03.821Z'),
      ),
      accessToken: 'A',
      refreshToken: 'R',
    );
  }

  @override
  Future<User> register({required String firstName, required String lastName, required String email, required String password}) async {
    return User(
      id: 'new-id',
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: 'USER',
      isActive: true,
      createdAt: DateTime.parse('2025-11-13T16:37:03.821Z'),
      updatedAt: DateTime.parse('2025-11-13T16:37:03.821Z'),
    );
  }
}

class _MemoryTokenStorage implements TokenStorage {
  String? a;
  String? r;

  @override
  Future<void> clearTokens() async { a = null; r = null; }

  @override
  Future<String?> getAccessToken() async => a;

  @override
  Future<String?> getRefreshToken() async => r;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async { a = accessToken; r = refreshToken; }
}

void main() {
  test('AuthRepository guarda tokens y retorna usuario', () async {
    final api = _FakeAuthApi();
    final storage = _MemoryTokenStorage();
    final repo = AuthRepository(api: api, storage: storage);

    final user = await repo.login(email: 'juan@example.com', password: 'secret');

    expect(user.email, 'juan@example.com');
    expect(await storage.getAccessToken(), 'A');
    expect(await storage.getRefreshToken(), 'R');
  });
}
