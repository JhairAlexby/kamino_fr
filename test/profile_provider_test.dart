import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/3_profile/data/profile_api.dart';

class _FakeRepo extends ProfileRepository {
  _FakeRepo(User u) : super(api: _FakeProfileApi()) { _u = u; }
  late User _u;
  @override
  Future<User> getProfile() async => _u;
}

class _FakeProfileApi implements ProfileApi {
  @override
  Future<User> getProfile() async => throw UnimplementedError();
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
  test('ProfileProvider carga usuario correctamente', () async {
    final user = User(
      id: '1',
      email: 'a@b.com',
      firstName: 'Ana',
      lastName: 'B',
      role: 'USER',
      isActive: true,
      createdAt: DateTime(2024,1,1),
      updatedAt: DateTime(2024,1,2),
    );
    final repo = _FakeRepo(user);
    final storage = _MemoryTokenStorage()..a = 'tkn';
    final appState = AppState();
    final vm = ProfileProvider(repo: repo, storage: storage, appState: appState);
    await vm.loadProfile();
    expect(vm.user, isNotNull);
    expect(vm.user!.email, 'a@b.com');
    expect(vm.errorMessage, isNull);
    expect(vm.sessionExpired, isFalse);
  }, skip: true);
}
