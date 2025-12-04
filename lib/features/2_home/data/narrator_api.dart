import 'package:dio/dio.dart';

String? parseNarratorText(Map<String, dynamic> json) {
  final inner = json['data'];
  if (inner is Map<String, dynamic>) {
    final text = inner['text'] as String?;
    if (text != null && text.trim().isNotEmpty) return text;
  }
  return null;
}

abstract class NarratorApi {
  Future<String?> getText(String placeId);
}

class NarratorApiImpl implements NarratorApi {
  final Dio _dio;
  NarratorApiImpl(this._dio);

  @override
  Future<String?> getText(String placeId) async {
    final res = await _dio.get('/api/v1/narrator/$placeId');
    final data = res.data as Map<String, dynamic>;
    return parseNarratorText(data);
  }
}
