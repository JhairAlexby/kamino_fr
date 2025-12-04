import 'dart:async';
import 'models/popularity_ranking.dart';
import 'popularity_api.dart';

class PopularityRepository {
  final PopularityApi api;
  final int maxRetries;
  final Duration ttl;

  PopularityRankingResponse? _cache;
  DateTime? _ts;

  PopularityRepository({
    required this.api,
    this.maxRetries = 3,
    this.ttl = const Duration(minutes: 5),
  });

  Future<PopularityRankingResponse> getRanking() async {
    final now = DateTime.now();
    if (_ts != null && _cache != null && now.difference(_ts!) < ttl) {
      return _cache!;
    }
    int attempt = 0;
    while (true) {
      try {
        final res = await api.getRanking();
        _cache = res;
        _ts = DateTime.now();
        return res;
      } catch (_) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt * attempt));
      }
    }
  }
}
