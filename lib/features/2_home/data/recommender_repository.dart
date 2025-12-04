import 'dart:async';
import 'models/recommendation.dart';
import 'recommender_api.dart';

class RecommenderRepository {
  final RecommenderApi api;
  final int maxRetries;
  final Duration ttl;

  RecommendResponse? _cache;
  DateTime? _ts;

  RecommenderRepository({
    required this.api,
    this.maxRetries = 3,
    this.ttl = const Duration(minutes: 3),
  });

  Future<RecommendResponse> getRecommendations() async {
    final now = DateTime.now();
    if (_ts != null && _cache != null && now.difference(_ts!) < ttl) {
      return _cache!;
    }

    int attempt = 0;
    while (true) {
      try {
        final res = await api.getRecommendations();
        _cache = _dedup(res);
        _ts = DateTime.now();
        return _cache!;
      } catch (_) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt * attempt));
      }
    }
  }

  RecommendResponse _dedup(RecommendResponse input) {
    final seen = <String>{};
    final list = <Recommendation>[];
    for (final r in input.recommendations) {
      if (seen.add(r.placeId)) list.add(r);
    }
    return RecommendResponse(
      success: input.success,
      userId: input.userId,
      strategy: input.strategy,
      recommendations: list,
    );
  }
}
