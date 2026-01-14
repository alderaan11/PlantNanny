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
}
