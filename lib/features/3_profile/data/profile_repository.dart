import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/3_profile/data/profile_api.dart';

class ProfileRepository {
  final ProfileApi api;
  ProfileRepository({required this.api});

  Future<User> getProfile() async {
    return await api.getProfile();
  }

  Future<User> updateProfile({String? gender, String? firstName, String? lastName, int? age}) async {
    return await api.updateProfile(gender: gender, firstName: firstName, lastName: lastName, age: age);
  }

  Future<void> updateTags(List<String> tags) async {
    await api.updateTags(tags);
  }

  Future<void> addFavorite(String placeId) async {
    await api.addFavorite(placeId);
  }

  Future<void> removeFavorite(String placeId) async {
    await api.removeFavorite(placeId);
  }
}

