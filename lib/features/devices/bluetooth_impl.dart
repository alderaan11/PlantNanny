import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:plant_nanny/core/bluetooth_service.dart' as core;

/// Implementation using flutter_blue_plus. This is intentionally general —
  final FlutterBluePlus _ble = FlutterBluePlus.instance;
/// it will look for devices with a name containing the provided `nameFilter`.
class FlutterBluetoothService extends core.BluetoothService {
  final Duration scanDuration;
  final String? nameFilter;

  FlutterBluetoothService({
    this.scanDuration = const Duration(seconds: 5),
    this.nameFilter,
  });

  @override
  Future<List<core.BluetoothEndpoint>> findNearEndpoints() async {
    final found = <FlutterBluetoothEndpoint>[];
    final completer = Completer<void>();

    FlutterBluePlus.startScan(timeout: scanDuration);

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final scanResult in results) {
        final device = scanResult.device;
        final name = device.platformName;
        if (name.isEmpty) continue;
        if (nameFilter == null || name.contains(nameFilter!)) {
          final endpoint = FlutterBluetoothEndpoint(device: device, name: name);
          if (!found.any((e) => e.id == endpoint.id)) found.add(endpoint);
        }
      }
    });

    FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning && !completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;
    await subscription.cancel();
    await FlutterBluePlus.stopScan();
    return found;
  }

  @override
  Future<bool> connect(core.BluetoothEndpoint endpoint) async {
    return await endpoint.connect();
  }
}

class FlutterBluetoothEndpoint implements core.BluetoothEndpoint {
  final BluetoothDevice device;
  @override
  final String? name;
  BluetoothCharacteristic? _tx; // write characteristic
  BluetoothCharacteristic? _rx; // notify/read characteristic
  StreamSubscription<List<int>>? _sub;
  final _incoming = StreamController<String>();

  FlutterBluetoothEndpoint({required this.device, this.name});

  @override
  String get id => device.remoteId.str;

  @override
  Future<bool> connect() async {
    try {
      await device
          .connect(license: License.free, autoConnect: false)
          .timeout(const Duration(seconds: 10));
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
        _sub = _rx!.lastValueStream.listen((data) {
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
    return device.isConnected;
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
