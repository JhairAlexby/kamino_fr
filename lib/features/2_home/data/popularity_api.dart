import 'package:dio/dio.dart';
import 'models/popularity_ranking.dart';

abstract class PopularityApi {
  Future<PopularityRankingResponse> getRanking();
}

class PopularityApiImpl implements PopularityApi {
  final Dio _dio;
  PopularityApiImpl(this._dio);

  @override
  Future<PopularityRankingResponse> getRanking() async {
    final res = await _dio.get('/api/popularity/ranking');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return PopularityRankingResponse.fromJson(data);
    }
    if (data is List) {
      return PopularityRankingResponse(success: true, totalPlaces: data.length, topPlaces: data.map((e) => RankingItem.fromJson(e as Map<String, dynamic>)).toList());
    }
    return PopularityRankingResponse(success: false, totalPlaces: 0, topPlaces: const []);
  }
}
