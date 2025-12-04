import 'narrator_api.dart';

class NarratorRepository {
  final NarratorApi api;
  NarratorRepository({required this.api});

  Future<String?> fetchNarrative(String placeId) {
    return api.getText(placeId);
  }
}
