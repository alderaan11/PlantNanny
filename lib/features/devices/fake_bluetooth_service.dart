import 'dart:async';
import '../../core/bluetooth_service.dart';

class FakeBluetoothService extends BluetoothService {
  @override
  Future<List<BluetoothEndpoint>> findNearEndpoints() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      FakeBluetoothEndpoint(
        id: 'ESP32-001',
        name: 'PlantNanny-ESP32-001',
      ),
      FakeBluetoothEndpoint(
        id: 'ESP32-002',
        name: 'PlantNanny-ESP32-002',
      ),
    ];
  }

  @override
  Future<bool> connect(BluetoothEndpoint endpoint) async {
    return await endpoint.connect();
  }
}

class FakeBluetoothEndpoint implements BluetoothEndpoint {
  @override
  final String id;
  
  @override
  final String? name;
  
  bool _isConnected = false;
  final _messageController = StreamController<String>.broadcast();
  
  FakeBluetoothEndpoint({required this.id, this.name});

  @override
  Future<bool> connect() async {
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = true;
    return true;
  }

  @override
  Future<bool> isConnected() async {
    return _isConnected;
  }

  @override
  Future<void> send(String message) async {
    if (!_isConnected) throw Exception('Not connected');
    await Future.delayed(const Duration(milliseconds: 500));
    if (message.contains('PIN:')) {
      _messageController.add('PIN_OK');
    } else if (message.contains('WIFI:')) {
      _messageController.add('WIFI_CONFIGURED');
    }
  }

  @override
  Future<String?> recv({Duration? timeout}) async {
    if (timeout != null) {
      try {
        return await _messageController.stream.first.timeout(timeout);
      } catch (_) {
        return null;
      }
    }
    return await _messageController.stream.first;
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    await _messageController.close();
  }
}
