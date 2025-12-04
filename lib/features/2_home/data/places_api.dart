import 'package:dio/dio.dart';
import 'models/place.dart';

abstract class PlacesApi {
  Future<List<Place>> nearby({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
  });

  Future<List<Place>> findAll({
    String? search,
    String? category,
    List<String>? tags,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isHiddenGem,
    String? sortBy,
    String? sortOrder,
  });

  Future<Place?> getById(String id);
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
    final res = await _dio.post(
      '/api/v1/places/nearby',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'limit': limit,
      },
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return const [];
  }

  @override
  Future<List<Place>> findAll({
    String? search,
    String? category,
    List<String>? tags,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isHiddenGem,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (tags != null && tags.isNotEmpty) query['tags'] = tags.join(',');
    if (latitude != null) query['latitude'] = latitude;
    if (longitude != null) query['longitude'] = longitude;
    if (radius != null) query['radius'] = radius;
    if (isHiddenGem != null) query['isHiddenGem'] = isHiddenGem;
    if (sortBy != null) query['sortBy'] = sortBy;
    if (sortOrder != null) query['sortOrder'] = sortOrder;

    final res = await _dio.get('/api/v1/places', queryParameters: query);
    final map = res.data as Map<String, dynamic>;
    final list = (map['data'] as List?) ?? const [];
    return list.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Place?> getById(String id) async {
    final res = await _dio.get('/api/v1/places/$id');
    final raw = res.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return Place.fromJson(data);
      }
    }
    return null;
  }
}
