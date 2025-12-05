import 'logbook_api.dart';
import 'logbook_entry.dart';

class LogbookRepository {
  final LogbookApi api;

  LogbookRepository({required this.api});

  Future<List<LogbookEntry>> getMyLogs() => api.getMyLogs();
  
  Future<LogbookEntry> createLog(LogbookEntry log) => api.createLog(log);
}