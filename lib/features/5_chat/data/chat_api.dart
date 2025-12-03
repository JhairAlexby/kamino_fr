import 'package:dio/dio.dart';

abstract class ChatApi {
  Future<String> sendMessage(String message);
}

class ChatApiImpl implements ChatApi {
  final Dio _dio;
  ChatApiImpl(this._dio);

  @override
  Future<String> sendMessage(String message) async {
    final res = await _dio.post('/api/v1/chat', data: {'message': message});
    final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};
    final inner = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : {};
    final answer = inner['answer'] as String?;
    if (answer == null || answer.isEmpty) {
      throw DioException(requestOptions: res.requestOptions, message: 'Respuesta vacía');
    }
    return answer;
  }
}

