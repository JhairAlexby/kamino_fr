import 'package:kamino_fr/features/1_auth/data/models/user.dart';
import 'package:kamino_fr/features/3_profile/data/profile_api.dart';

class ProfileRepository {
  final ProfileApi api;
  ProfileRepository({required this.api});

  Future<User> getProfile() async {
    return await api.getProfile();
  }
}

