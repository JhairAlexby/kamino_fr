import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/3_profile/data/profile_api.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({String? gender, String? firstName, String? lastName, int? age});
  Future<void> updateTags(List<String> tags);
  Future<void> addFavorite(String placeId);
  Future<void> removeFavorite(String placeId);
  Future<void> addVisited(String placeId);
  Future<void> removeVisited(String placeId);
  Future<Place> getPlaceById(String placeId);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi api;
  ProfileRepositoryImpl({required this.api});

  @override
  Future<User> getProfile() => api.getProfile();

  @override
  Future<User> updateProfile({String? gender, String? firstName, String? lastName, int? age}) =>
      api.updateProfile(gender: gender, firstName: firstName, lastName: lastName, age: age);

  @override
  Future<void> updateTags(List<String> tags) => api.updateTags(tags);

  @override
  Future<void> addFavorite(String placeId) => api.addFavorite(placeId);

  @override
  Future<void> removeFavorite(String placeId) => api.removeFavorite(placeId);

  @override
  Future<void> addVisited(String placeId) => api.addVisited(placeId);

  @override
  Future<void> removeVisited(String placeId) => api.removeVisited(placeId);

  @override
  Future<Place> getPlaceById(String placeId) => api.getPlaceById(placeId);
}

