import 'package:dio/dio.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';

class HttpClient {
  final Dio dio;

  HttpClient(EnvironmentConfig config, TokenStorage tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: Duration(milliseconds: config.apiTimeout),
            receiveTimeout: Duration(milliseconds: config.apiTimeout),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': config.apiKey,
            },
          ),
        ) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode ?? 0;
        if (status == 401) {
          await tokenStorage.clearTokens();
        }
        handler.next(error);
      },
    ));
  }
}
