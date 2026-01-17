import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'server_config_provider.dart';

const String _mqttHostKey = 'mqtt_broker_host';
const String _mqttPortKey = 'mqtt_broker_port';
const String _mqttUsernameKey = 'mqtt_username';
const String _mqttPasswordKey = 'mqtt_password';
const String _mqttEnabledKey = 'mqtt_enabled';

/// Default MQTT broker settings based on platform
String get _defaultMqttHost {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return '10.0.2.2'; // Android emulator host
  }
  return '127.0.0.1';
}

const int _defaultMqttPort = 1883;
const String _defaultMqttUsername = 'plantnanny_device';
const String _defaultMqttPassword = 'device_secret_2024';

/// MQTT Broker configuration model
class MqttConfig {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool enabled;

  const MqttConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.enabled = true,
  });

  MqttConfig copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    bool? enabled,
  }) {
    return MqttConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Convert to format for sending via BLE to ESP32
  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  /// Create from JSON (e.g., from server response)
  factory MqttConfig.fromJson(Map<String, dynamic> json) {
    return MqttConfig(
      host: json['host'] as String? ?? _defaultMqttHost,
      port: json['port'] as int? ?? _defaultMqttPort,
      username: json['username'] as String? ?? _defaultMqttUsername,
      password: json['password'] as String? ?? _defaultMqttPassword,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Get broker URI for display
  String get brokerUri => '$host:$port';

  @override
  String toString() => 'MqttConfig(host: $host, port: $port, enabled: $enabled)';
}

/// State notifier for MQTT configuration
class MqttConfigNotifier extends StateNotifier<MqttConfig> {
  final SharedPreferences _prefs;

  MqttConfigNotifier(this._prefs)
    : super(MqttConfig(
        host: _prefs.getString(_mqttHostKey) ?? _defaultMqttHost,
        port: _prefs.getInt(_mqttPortKey) ?? _defaultMqttPort,
        username: _prefs.getString(_mqttUsernameKey) ?? _defaultMqttUsername,
        password: _prefs.getString(_mqttPasswordKey) ?? _defaultMqttPassword,
        enabled: _prefs.getBool(_mqttEnabledKey) ?? true,
      ));

  /// Update the full MQTT configuration
  Future<void> setConfig(MqttConfig config) async {
    await _prefs.setString(_mqttHostKey, config.host);
    await _prefs.setInt(_mqttPortKey, config.port);
    await _prefs.setString(_mqttUsernameKey, config.username);
    await _prefs.setString(_mqttPasswordKey, config.password);
    await _prefs.setBool(_mqttEnabledKey, config.enabled);
    state = config;
  }

  /// Update MQTT broker host
  Future<void> setHost(String host) async {
    await _prefs.setString(_mqttHostKey, host);
    state = state.copyWith(host: host);
  }

  /// Update MQTT broker port
  Future<void> setPort(int port) async {
    await _prefs.setInt(_mqttPortKey, port);
    state = state.copyWith(port: port);
  }

  /// Update MQTT credentials
  Future<void> setCredentials(String username, String password) async {
    await _prefs.setString(_mqttUsernameKey, username);
    await _prefs.setString(_mqttPasswordKey, password);
    state = state.copyWith(username: username, password: password);
  }

  /// Toggle MQTT enabled state
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_mqttEnabledKey, enabled);
    state = state.copyWith(enabled: enabled);
  }

  /// Derive MQTT broker host from server URL
  Future<void> deriveFromServerUrl(String serverUrl) async {
    try {
      final uri = Uri.parse(serverUrl);
      final host = uri.host;
      if (host.isNotEmpty && host != '127.0.0.1' && host != 'localhost') {
        await setHost(host);
      }
    } catch (_) {
      // Invalid URL, keep current settings
    }
  }

  /// Reset to default configuration
  Future<void> resetToDefault() async {
    await _prefs.remove(_mqttHostKey);
    await _prefs.remove(_mqttPortKey);
    await _prefs.remove(_mqttUsernameKey);
    await _prefs.remove(_mqttPasswordKey);
    await _prefs.remove(_mqttEnabledKey);
    state = MqttConfig(
      host: _defaultMqttHost,
      port: _defaultMqttPort,
      username: _defaultMqttUsername,
      password: _defaultMqttPassword,
      enabled: true,
    );
  }
}

/// Provider for the MQTT configuration notifier
final mqttConfigProvider =
    StateNotifierProvider<MqttConfigNotifier, MqttConfig>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return MqttConfigNotifier(prefs);
    });

/// Convenience provider to get just the MQTT broker URI
final mqttBrokerUriProvider = Provider<String>((ref) {
  final config = ref.watch(mqttConfigProvider);
  return config.brokerUri;
});
