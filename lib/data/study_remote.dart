import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_base.dart';
import 'auth_service.dart';

Future<void> pushStudySnapshot(Map<String, dynamic> payload) async {
  final token = await AuthService.getToken();
  if (token == null || token.isEmpty) return;
  try {
    await http
        .put(
          Uri.parse('${resolveApiBaseUrl()}/user/study-data'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 25));
  } catch (_) {}
}

Future<Map<String, dynamic>?> fetchStudySnapshot() async {
  final token = await AuthService.getToken();
  if (token == null || token.isEmpty) return null;
  try {
    final r = await http
        .get(
          Uri.parse('${resolveApiBaseUrl()}/user/study-data'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 25));
    if (r.statusCode < 200 || r.statusCode >= 300) return null;
    final decoded = jsonDecode(r.body);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {}
  return null;
}
