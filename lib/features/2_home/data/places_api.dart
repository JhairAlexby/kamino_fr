import 'package:dio/dio.dart';
import 'models/place.dart';

abstract class PlacesApi {
  Future<List<Place>> nearby({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
  });
}

class PlacesApiImpl implements PlacesApi {
  final Dio _dio;
  PlacesApiImpl(this._dio);

  @override
  Future<List<Place>> nearby({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
  }) async {
    final res = await _dio.get('/api/v1/places');
    final map = res.data as Map<String, dynamic>;
    final list = (map['data'] as List?) ?? const [];
    return list.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }
}
