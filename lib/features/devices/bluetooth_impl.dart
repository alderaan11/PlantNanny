import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/bluetooth_service.dart';

/// Implementation using flutter_blue_plus. This is intentionally general —
class FlutterBluetoothService extends BluetoothService {
  final FlutterBluePlus _ble = FlutterBluePlus.instance;
  final Duration scanDuration;
  final String? nameFilter;

  FlutterBluetoothService({this.scanDuration = const Duration(seconds: 5), this.nameFilter});

  @override
  Future<List<BluetoothEndpoint>> findNearEndpoints() async {
    final found = <FlutterBluetoothEndpoint>[];
    final completer = Completer<void>();

    _ble.startScan(timeout: scanDuration).listen((scanResult) {
      final device = scanResult.device;
      final name = device.name;
      if (name == null || name.isEmpty) return;
      if (nameFilter == null || name.contains(nameFilter!)) {
        final endpoint = FlutterBluetoothEndpoint(device: device, name: name);
        if (!found.any((e) => e.id == endpoint.id)) found.add(endpoint);
      }
    }, onDone: () => completer.complete(), onError: (_) => completer.complete());

    await completer.future;
    _ble.stopScan();
    return found;
  }

  @override
  Future<bool> connect(BluetoothEndpoint endpoint) async {
    return await endpoint.connect();
  }
}

class FlutterBluetoothEndpoint implements BluetoothEndpoint {
  final BluetoothDevice device;
  final String? name;
  BluetoothCharacteristic? _tx; // write characteristic
  BluetoothCharacteristic? _rx; // notify/read characteristic
  StreamSubscription<List<int>>? _sub;
  final _incoming = StreamController<String>();

  FlutterBluetoothEndpoint({required this.device, this.name});

  @override
  String get id => device.id.id;

  @override
  Future<bool> connect() async {
    try {
      await device.connect(autoConnect: false).timeout(const Duration(seconds: 10));
    } catch (_) {}

    final services = await device.discoverServices();

    // Heuristic: pick the first writable characteristic and the first notifiable one
    for (final s in services) {
      for (final c in s.characteristics) {
        if (_tx == null && c.properties.write) _tx = c;
        if (_rx == null && (c.properties.notify || c.properties.read)) _rx = c;
      }
    }

    if (_rx != null) {
      try {
        await _rx!.setNotifyValue(true);
        _sub = _rx!.value.listen((data) {
          try {
            final msg = utf8.decode(data);
            _incoming.add(msg);
          } catch (_) {}
        });
      } catch (_) {}
    }

    return await isConnected();
  }

  @override
  Future<bool> isConnected() async {
    final state = await device.state.first;
    return state == BluetoothDeviceState.connected;
  }

  @override
  Future<void> send(String message) async {
    if (_tx == null) throw Exception('No writable characteristic found');
    final bytes = utf8.encode(message);
    await _tx!.write(bytes, withoutResponse: false);
  }

  @override
  Future<String?> recv({Duration? timeout}) async {
    if (timeout == null) return await _incoming.stream.first;
    try {
      return await _incoming.stream.first.timeout(timeout);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _incoming.close();
    try {
      await device.disconnect();
    } catch (_) {}
  }
}
