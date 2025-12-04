import 'package:dio/dio.dart';
import 'models/recommendation.dart';

abstract class RecommenderApi {
  Future<RecommendResponse> getRecommendations();
}

class RecommenderApiImpl implements RecommenderApi {
  final Dio _dio;
  RecommenderApiImpl(this._dio);

  @override
  Future<RecommendResponse> getRecommendations() async {
    final res = await _dio.get('/api/recommender/recommend');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return RecommendResponse.fromJson(data);
    }
    return RecommendResponse(success: false, userId: '', strategy: '', recommendations: const []);
  }
}
