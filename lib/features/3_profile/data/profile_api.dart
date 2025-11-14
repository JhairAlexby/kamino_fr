import 'package:dio/dio.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';

abstract class ProfileApi {
  Future<User> getProfile();
}

class ProfileApiImpl implements ProfileApi {
  final Dio _dio;
  ProfileApiImpl(this._dio);

  @override
  Future<User> getProfile() async {
    final res = await _dio.get('/api/users/profile');
    final data = res.data as Map<String, dynamic>;
    return User.fromJson(data);
  }
}

