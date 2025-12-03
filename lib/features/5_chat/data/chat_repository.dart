import 'chat_api.dart';

class ChatRepository {
  final ChatApi api;
  ChatRepository({required this.api});

  Future<String> ask(String message) => api.sendMessage(message);
}

