import 'package:dio/dio.dart';
import 'logbook_entry.dart';

abstract class LogbookApi {
  Future<List<LogbookEntry>> getMyLogs();
  Future<LogbookEntry> createLog(LogbookEntry log);
}

class LogbookApiImpl implements LogbookApi {
  final Dio _dio;
  LogbookApiImpl(this._dio);

  @override
  Future<List<LogbookEntry>> getMyLogs() async {
    try {
      // Intentamos con /logbook asumiendo que la base ya tiene el prefijo correcto o es relativo
      final res = await _dio.get('/logbook');
      
      final data = res.data;
      List list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'];
      }
      
      return list.map((e) => LogbookEntry.fromJson(e)).toList();
    } catch (e) {
      print('LogbookApi: Error fetching logs: $e');
      return [];
    }
  }

  @override
  Future<LogbookEntry> createLog(LogbookEntry log) async {
    final res = await _dio.post('/logbook', data: log.toJson());
    return LogbookEntry.fromJson(res.data);
  }
}