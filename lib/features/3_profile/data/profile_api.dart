import 'package:dio/dio.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';

abstract class ProfileApi {
  Future<User> getProfile();
  Future<User> updateProfile({String? gender, String? firstName, String? lastName, int? age});
  Future<void> updateTags(List<String> tags);
  Future<void> addFavorite(String placeId);
  Future<void> removeFavorite(String placeId);
  Future<void> addVisited(String placeId);
  Future<void> removeVisited(String placeId);
  Future<Place> getPlaceById(String placeId);
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

  @override
  Future<User> updateProfile({String? gender, String? firstName, String? lastName, int? age}) async {
    final body = <String, dynamic>{};
    if (gender != null) body['gender'] = gender;
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (age != null) body['age'] = age;

    final res = await _dio.put('/api/users/profile', data: body);
    final data = res.data as Map<String, dynamic>;
    return User.fromJson(data);
  }

  @override
  Future<void> updateTags(List<String> tags) async {
    await _dio.put('/api/users/profile/tags', data: {'tags': tags});
  }

  @override
  Future<void> addFavorite(String placeId) async {
    await _dio.post('/api/favorites', data: {'placeId': placeId});
  }

  @override
  Future<void> removeFavorite(String placeId) async {
    await _dio.delete('/api/favorites/$placeId');
  }

  @override
  Future<void> addVisited(String placeId) async {
    await _dio.post('/profile/visited', data: {'placeId': placeId});
  }

  @override
  Future<void> removeVisited(String placeId) async {
    await _dio.delete('/profile/visited/$placeId');
  }

  @override
  Future<Place> getPlaceById(String placeId) async {
    final response = await _dio.get('/places/$placeId');
    return Place.fromJson(response.data);
  }
}

