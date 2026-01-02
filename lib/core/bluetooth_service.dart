import 'dart:async';

/// Simple Bluetooth service interface used by the app to discover and
/// exchange text messages with endpoints (device that accepts Wi‑Fi creds).
class BluetoothService {
  /// Find nearby endpoints. Returns a list (may be empty).
  Future<List<BluetoothEndpoint>> findNearEndpoints() async => [];

  /// Connect to an endpoint. Returns true on success.
  Future<bool> connect(BluetoothEndpoint endpoint) async => false;
}

/// Represents one connectable Bluetooth endpoint.
abstract class BluetoothEndpoint {
  String get id;
  String? get name;

  Future<bool> connect();
  Future<bool> isConnected();
  Future<void> send(String message);
  /// Returns next received message (may wait until one is available).
  Future<String?> recv({Duration? timeout});
  Future<void> close();
}
