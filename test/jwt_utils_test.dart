import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:kamino_fr/core/auth/jwt_utils.dart';

String _base64UrlNoPad(String input) {
  final enc = base64Url.encode(utf8.encode(input));
  return enc.replaceAll('=', '');
}

String _fakeJwtWithExp(int expSeconds) {
  final header = _base64UrlNoPad('{"alg":"HS256","typ":"JWT"}');
  final payload = _base64UrlNoPad('{"exp":$expSeconds}');
  return '$header.$payload.';
}

void main() {
  test('JwtUtils.isValid true cuando exp > ahora', () {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token = _fakeJwtWithExp(nowSec + 3600);
    expect(JwtUtils.isValid(token), isTrue);
  });

  test('JwtUtils.isValid false cuando exp <= ahora', () {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token = _fakeJwtWithExp(nowSec - 10);
    expect(JwtUtils.isValid(token), isFalse);
  });
}