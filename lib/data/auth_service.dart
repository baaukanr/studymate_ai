import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_base.dart';

class AuthUser {
  final String id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as String? ?? '').trim(),
      firstName: (json['firstName'] as String? ?? '').trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
    );
  }
}

class AuthService {
  static const _keyToken = 'studymate_token';
  static const _keyUserJson = 'studymate_user_json';

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyToken);
  }

  static Future<void> _saveSession(String token, AuthUser user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyToken, token);
    await p.setString(_keyUserJson, jsonEncode({
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'name': user.name,
      'email': user.email,
    }));
  }

  static Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyToken);
    await p.remove(_keyUserJson);
  }

  static Future<bool> isAuthorized() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  static Future<AuthUser?> getCachedUser() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(m);
    } catch (_) {
      return null;
    }
  }

  static Future<AuthUser?> refreshCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    try {
      final r = await http
          .get(
            Uri.parse('${resolveApiBaseUrl()}/auth/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
      if (r.statusCode < 200 || r.statusCode >= 300) return null;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final u = body['user'];
      if (u is! Map<String, dynamic>) return null;
      final user = AuthUser.fromJson(u);
      final p = await SharedPreferences.getInstance();
      await p.setString(_keyUserJson, jsonEncode({
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'name': user.name,
        'email': user.email,
      }));
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('${resolveApiBaseUrl()}/auth/register'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName.trim(),
              'lastName': lastName.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));
      final body = _parseMap(r.body);
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return _errMessage(body) ?? 'Ошибка регистрации (${r.statusCode})';
      }
      final token = body['token'];
      final userRaw = body['user'];
      if (token is! String || userRaw is! Map<String, dynamic>) {
        return 'Некорректный ответ сервера';
      }
      await _saveSession(token, AuthUser.fromJson(userRaw));
      return null;
    } catch (_) {
      return 'Не удалось связаться с сервером. Запустите proxy (server/npm start).';
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('${resolveApiBaseUrl()}/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));
      final body = _parseMap(r.body);
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return _errMessage(body) ?? 'Неверный email или пароль';
      }
      final token = body['token'];
      final userRaw = body['user'];
      if (token is! String || userRaw is! Map<String, dynamic>) {
        return 'Некорректный ответ сервера';
      }
      await _saveSession(token, AuthUser.fromJson(userRaw));
      return null;
    } catch (_) {
      return 'Не удалось связаться с сервером. Запустите proxy (server/npm start).';
    }
  }

  static Future<void> logout() => clearSession();

  static Map<String, dynamic> _parseMap(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map<String, dynamic>) return d;
    } catch (_) {}
    return {};
  }

  static String? _errMessage(Map<String, dynamic> body) {
    final e = body['error'];
    if (e is Map && e['message'] is String) return e['message'] as String;
    return null;
  }
}
