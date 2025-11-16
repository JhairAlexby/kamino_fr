import 'dart:convert';

class JwtUtils {
  static bool isValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return false;
      final payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final padding = '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64.decode(payload + padding));
      final map = json.decode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is! int) return false;
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp > nowSec;
    } catch (_) {
      return false;
    }
  }
}