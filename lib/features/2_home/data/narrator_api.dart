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
    try {
      final res = await _dio.get(
        '/api/v1/narrator/$placeId',
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      );
      final raw = res.data;
      if (raw is Map<String, dynamic>) {
        final ok = raw['success'] == true && (raw['statusCode'] == 200 || res.statusCode == 200);
        if (!ok) return null;
        return parseNarratorText(raw);
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
