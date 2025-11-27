import 'package:dio/dio.dart';
import 'package:kamino_fr/features/1_auth/data/models/auth_response.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';

abstract class AuthApi {
  Future<AuthResponse> login({required String email, required String password});
  Future<User> register({required String firstName, required String lastName, required String email, required String password, String? gender});
  Future<AuthResponse> refresh({required String refreshToken});
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

  @override
  Future<User> register({required String firstName, required String lastName, required String email, required String password, String? gender}) async {
    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
    if (gender != null) body['gender'] = gender;
    final res = await _dio.post(
      '/api/auth/register',
      data: body,
    );
    final data = res.data as Map<String, dynamic>;
    return User.fromJson(data);
  }

  @override
  Future<AuthResponse> refresh({required String refreshToken}) async {
    final res = await _dio.post(
      '/api/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }
}
