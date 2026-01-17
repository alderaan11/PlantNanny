import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _serverUrlKey = 'server_url';

/// Default server URL based on platform
String get _defaultServerUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  // Use 127.0.0.1 instead of localhost for more reliable IPv4 resolution
  return 'http://127.0.0.1:8080';
}

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// State notifier for server URL configuration
class ServerConfigNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  ServerConfigNotifier(this._prefs)
    : super(_prefs.getString(_serverUrlKey) ?? _defaultServerUrl);

  /// Update the server URL
  Future<void> setServerUrl(String url) async {
    await _prefs.setString(_serverUrlKey, url);
    state = url;
  }

  /// Reset to default URL
  Future<void> resetToDefault() async {
    await _prefs.remove(_serverUrlKey);
    state = _defaultServerUrl;
  }
}

/// Provider for the server configuration notifier
final serverConfigProvider =
    StateNotifierProvider<ServerConfigNotifier, String>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ServerConfigNotifier(prefs);
    });
