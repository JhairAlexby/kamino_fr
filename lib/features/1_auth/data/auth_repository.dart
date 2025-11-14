import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/features/1_auth/data/auth_api.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';

class AuthRepository {
  final AuthApi api;
  final TokenStorage storage;

  AuthRepository({required this.api, required this.storage});

  Future<User> login({required String email, required String password}) async {
    final r = await api.login(email: email, password: password);
    await storage.saveTokens(accessToken: r.accessToken, refreshToken: r.refreshToken);
    return r.user;
  }

  Future<User> register({required String firstName, required String lastName, required String email, required String password}) async {
    final user = await api.register(firstName: firstName, lastName: lastName, email: email, password: password);
    return user;
  }
}
