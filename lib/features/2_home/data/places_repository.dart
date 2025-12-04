import 'dart:async';
import 'models/place.dart';
import 'places_api.dart';

class PlacesRepository {
  final PlacesApi api;
  final int maxRetries;
  final Duration ttl;

  final Map<String, List<Place>> _cache = {};
  final Map<String, DateTime> _ts = {};
  final Map<String, Place> _cacheById = {};
  final Map<String, DateTime> _tsById = {};

  PlacesRepository({
    required this.api,
    this.maxRetries = 3,
    this.ttl = const Duration(minutes: 3),
  });

  Future<List<Place>> getNearby({
    required double latitude,
    required double longitude,
    required double radius,
    int limit = 100,
  }) async {
    final key = _key(latitude, longitude, radius, limit);
    final now = DateTime.now();
    final ts = _ts[key];
    if (ts != null && now.difference(ts) < ttl) {
      final cached = _cache[key];
      if (cached != null) return cached;
    }

    int attempt = 0;
    while (true) {
      try {
        final items = await api.nearby(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          limit: limit,
        );
        final dedup = _dedup(items);
        _cache[key] = dedup;
        _ts[key] = DateTime.now();
        return dedup;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt * attempt));
      }
    }
  }

  // REMOVED DUPLICATE findAll METHOD HERE

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
    int attempt = 0;
    while (true) {
      try {
        final items = await api.findAll(
          search: search,
          category: category,
          tags: tags,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          isHiddenGem: isHiddenGem,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return _dedup(items);
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt * attempt));
      }
    }
  }

  List<Place> _dedup(List<Place> input) {
    final seen = <String>{};
    final out = <Place>[];
    for (final p in input) {
      if (seen.add(p.id)) out.add(p);
    }
    return out;
  }

  String _key(double lat, double lng, double radius, int limit) {
    final rl = (radius / 10).round() * 10; // redondeo a 10m
    final latR = double.parse(lat.toStringAsFixed(5));
    final lngR = double.parse(lng.toStringAsFixed(5));
    return 'lat=$latR|lng=$lngR|r=$rl|l=$limit';
  }

  Future<Place?> getById(String id) async {
    final now = DateTime.now();
    final ts = _tsById[id];
    if (ts != null && now.difference(ts) < ttl) {
      final cached = _cacheById[id];
      if (cached != null) return cached;
    }

    int attempt = 0;
    while (true) {
      try {
        final item = await api.getById(id);
        if (item != null) {
          _cacheById[id] = item;
          _tsById[id] = DateTime.now();
        }
        return item;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt * attempt));
      }
    }
  }
}
