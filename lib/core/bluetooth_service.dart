import 'dart:async';

class BluetoothService {
  Future<List<BluetoothEndpoint>> findNearEndpoints() async => [];
  Future<bool> connect(BluetoothEndpoint endpoint) async => false;
}

abstract class BluetoothEndpoint {
  String get id;
  String? get name;

  Future<bool> connect();
  Future<bool> isConnected();
  Future<void> send(String message);
  Future<String?> recv({Duration? timeout});
  Future<void> close();
  
  /// Get the device UUID from the ESP32's BLE characteristic
  Future<String?> getDeviceId();
  
  /// Get the device's IP address after WiFi connection
  Future<String?> getIpAddress();
  
  /// Wait for the device to report its IP address
  Future<String?> waitForIpAddress({Duration timeout = const Duration(seconds: 30)});
}
