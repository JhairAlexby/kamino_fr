import 'package:dio/dio.dart';
import 'package:kamino_fr/features/1_auth/data/models/auth_response.dart';

abstract class AuthApi {
  Future<AuthResponse> login({required String email, required String password});
}

class AuthApiImpl implements AuthApi {
  final Dio _dio;
  AuthApiImpl(this._dio);

  @override
  Future<AuthResponse> login({required String email, required String password}) async {
    final res = await _dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }
}
