import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';
import 'package:kamino_fr/features/2_home/data/recommender_api.dart';
import 'package:kamino_fr/features/2_home/data/recommender_repository.dart';

class _FakeApi implements RecommenderApi {
  @override
  Future<RecommendResponse> getRecommendations() async {
    return RecommendResponse(
      success: true,
      userId: 'u',
      strategy: 's',
      recommendations: [
        Recommendation(
          placeId: 'a',
          name: 'A',
          category: 'c',
          tags: const [],
          similarityScore: 0.5,
          finalScore: 0.6,
          isHiddenGem: true,
          reason: 'r',
        ),
        Recommendation(
          placeId: 'a',
          name: 'A2',
          category: 'c',
          tags: const [],
          similarityScore: 0.4,
          finalScore: 0.7,
          isHiddenGem: false,
          reason: 'r2',
        ),
      ],
    );
  }
}

void main() {
  test('repository dedup by placeId', () async {
    final repo = RecommenderRepository(api: _FakeApi());
    final res = await repo.getRecommendations();
    expect(res.recommendations.length, 1);
    expect(res.recommendations.first.placeId, 'a');
  });
}
