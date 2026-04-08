import 'package:flutter/foundation.dart';

/// Базовый URL proxy (auth, /chat, /plan/generate).
/// На Android-эмуляторе хост ПК — 10.0.2.2.
String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('AUTH_API_BASE_URL');
  if (fromEnv.trim().isNotEmpty) {
    return fromEnv.trim().replaceAll(RegExp(r'/+$'), '');
  }
  if (kIsWeb) return 'http://localhost:8787';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8787';
  }
  return 'http://localhost:8787';
}
