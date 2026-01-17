import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../../core/bluetooth_service.dart' as core;
import '../../core/bluetooth_permissions.dart';

void _log(String message) {
  if (kDebugMode) print('[BLE] $message');
}

class RealBluetoothService extends core.BluetoothService {
  static const String configServiceUuid =
      '12345678-1234-5678-1234-56789abcdef0';
  static const String wifiSsidCharUuid = '12345678-1234-5678-1234-56789abcdef1';
  static const String wifiPassCharUuid = '12345678-1234-5678-1234-56789abcdef2';
  static const String mqttHostCharUuid = '12345678-1234-5678-1234-56789abcdef3';
  static const String mqttPortCharUuid = '12345678-1234-5678-1234-56789abcdef4';
  static const String configStatusCharUuid =
      '12345678-1234-5678-1234-56789abcdef5';
  static const String deviceIdCharUuid = '12345678-1234-5678-1234-56789abcdef6';
  static const String ipAddressCharUuid =
      '12345678-1234-5678-1234-56789abcdef7';
  static const String serverIdCharUuid = '12345678-1234-5678-1234-56789abcdef8';
  static const String wifiNetworksCharUuid =
      '12345678-1234-5678-1234-56789abcdef9';
  static const String pinCharUuid = '12345678-1234-5678-1234-56789abcdefa';
  static const String mqttUsernameCharUuid =
      '12345678-1234-5678-1234-56789abcdefb';
  static const String mqttPasswordCharUuid =
      '12345678-1234-5678-1234-56789abcdefc';

  @override
  Future<List<core.BluetoothEndpoint>> findNearEndpoints() async {
    final List<core.BluetoothEndpoint> endpoints = [];

    // Request permissions before scanning
    _log('Requesting Bluetooth permissions...');
    final permissionsGranted = await BluetoothPermissions.requestPermissions();
    _log('Permissions granted: $permissionsGranted');

    if (!permissionsGranted) {
      _log('Bluetooth permissions not granted');
      throw Exception(
        'Bluetooth permissions not granted. Please enable Location and Nearby Devices permissions.',
      );
    }

    if (await fbp.FlutterBluePlus.isSupported == false) {
      _log('Bluetooth not supported');
      throw Exception('Bluetooth not supported on this device');
    }

    _log('Checking adapter state...');
    final adapterState = await fbp.FlutterBluePlus.adapterState.first;
    _log('Adapter state: $adapterState');

    if (adapterState != fbp.BluetoothAdapterState.on) {
      _log('Waiting for adapter to turn on...');
      await fbp.FlutterBluePlus.adapterState
          .where((state) => state == fbp.BluetoothAdapterState.on)
          .first
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Bluetooth is not enabled');
            },
          );
    }

    // Stop any existing scan first
    if (fbp.FlutterBluePlus.isScanningNow) {
      _log('Stopping existing scan...');
      await fbp.FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _log('Starting BLE scan...');

    // Use onScanResults instead of scanResults for better Linux compatibility
    final subscription = fbp.FlutterBluePlus.onScanResults.listen(
      (results) {
        _log('onScanResults: ${results.length} devices');
        for (final result in results) {
          final name = result.device.platformName;
          final localName = result.advertisementData.advName;
          final effectiveName = name.isNotEmpty ? name : localName;

          _log(
            '  Device: ${result.device.remoteId} name="$effectiveName" rssi=${result.rssi}',
          );

          final matchesByName = effectiveName.toLowerCase().contains(
            'plantnanny',
          );
          final matchesByService = result.advertisementData.serviceUuids.any(
            (uuid) =>
                uuid.toString().toLowerCase() ==
                configServiceUuid.toLowerCase(),
          );

          if (matchesByName || matchesByService) {
            _log('  -> MATCH! Adding to endpoints');
            if (endpoints.every((e) => e.id != result.device.remoteId.str)) {
              endpoints.add(
                RealBluetoothEndpoint(
                  device: result.device,
                  deviceName: effectiveName.isNotEmpty
                      ? effectiveName
                      : 'PlantNanny Device',
                ),
              );
            }
          }
        }
      },
      onError: (e) {
        _log('Scan error: $e');
      },
    );

    // Also check bonded/system devices (already known to BlueZ)
    _log('Checking bonded devices...');
    try {
      final bondedDevices = await fbp.FlutterBluePlus.bondedDevices;
      _log('Bonded devices: ${bondedDevices.length}');
      for (final device in bondedDevices) {
        final name = device.platformName;
        _log('  Bonded device: ${device.remoteId} name="$name"');
        if (name.toLowerCase().contains('plantnanny')) {
          _log('  -> MATCH in bonded devices!');
          if (endpoints.every((e) => e.id != device.remoteId.str)) {
            endpoints.add(
              RealBluetoothEndpoint(
                device: device,
                deviceName: name.isNotEmpty ? name : 'PlantNanny Device',
              ),
            );
          }
        }
      }
    } catch (e) {
      _log('Error getting bonded devices: $e');
    }

    // Start scan
    try {
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        continuousUpdates: true,
      );
      _log('Scan started, waiting for results...');
    } catch (e) {
      _log('Error starting scan: $e');
      await subscription.cancel();
      rethrow;
    }

    // Wait for scan to complete
    await Future.delayed(const Duration(seconds: 10));

    try {
      await fbp.FlutterBluePlus.stopScan();
    } catch (e) {
      _log('Error stopping scan: $e');
    }
    await subscription.cancel();

    _log('Scan complete. Found ${endpoints.length} devices.');
    return endpoints;
  }

  @override
  Future<bool> connect(core.BluetoothEndpoint endpoint) async {
    if (endpoint is RealBluetoothEndpoint) {
      return endpoint.connect();
    }
    return false;
  }
}

class RealBluetoothEndpoint implements core.BluetoothEndpoint {
  final fbp.BluetoothDevice device;
  final String _name;

  fbp.BluetoothCharacteristic? _wifiSsidChar;
  fbp.BluetoothCharacteristic? _wifiPassChar;
  fbp.BluetoothCharacteristic? _mqttHostChar;
  fbp.BluetoothCharacteristic? _mqttPortChar;
  fbp.BluetoothCharacteristic? _mqttUsernameChar;
  fbp.BluetoothCharacteristic? _mqttPasswordChar;
  fbp.BluetoothCharacteristic? _configStatusChar;
  fbp.BluetoothCharacteristic? _deviceIdChar;
  fbp.BluetoothCharacteristic? _ipAddressChar;
  fbp.BluetoothCharacteristic? _serverIdChar;
  fbp.BluetoothCharacteristic? _wifiNetworksChar;
  fbp.BluetoothCharacteristic? _pinChar;

  StreamSubscription? _statusSubscription;
  StreamSubscription? _ipSubscription;
  final StreamController<String> _messageController =
      StreamController.broadcast();

  RealBluetoothEndpoint({required this.device, String? deviceName})
    : _name = deviceName ?? 'Unknown';

  @override
  String get id => device.remoteId.str;

  @override
  String? get name => _name;

  @override
  Future<bool> connect() async {
    try {
      _log('Connecting to ${device.remoteId}');
      await device.connect(
        license: fbp.License.free,
        timeout: const Duration(seconds: 15),
      );
      await Future.delayed(const Duration(milliseconds: 500));

      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            RealBluetoothService.configServiceUuid.toLowerCase()) {
          _log('Found PlantNanny config service');
          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();
            _mapCharacteristic(uuid, char);
          }
        }
      }

      if (_configStatusChar != null) {
        await _configStatusChar!.setNotifyValue(true);
        _statusSubscription = _configStatusChar!.onValueReceived.listen((
          value,
        ) {
          final status = utf8.decode(value);
          _log('Status: $status');
          _messageController.add(status);
        });
      }

      if (_ipAddressChar != null) {
        await _ipAddressChar!.setNotifyValue(true);
        _ipSubscription = _ipAddressChar!.onValueReceived.listen((value) {
          final ip = utf8.decode(value);
          if (ip.isNotEmpty) {
            _log('IP: $ip');
            _messageController.add('IP:$ip');
          }
        });
      }

      return _wifiSsidChar != null && _wifiPassChar != null && _pinChar != null;
    } catch (e) {
      _log('Connect error: $e');
      return false;
    }
  }

  void _mapCharacteristic(String uuid, fbp.BluetoothCharacteristic char) {
    final mapping = {
      RealBluetoothService.wifiSsidCharUuid: () => _wifiSsidChar = char,
      RealBluetoothService.wifiPassCharUuid: () => _wifiPassChar = char,
      RealBluetoothService.mqttHostCharUuid: () => _mqttHostChar = char,
      RealBluetoothService.mqttPortCharUuid: () => _mqttPortChar = char,
      RealBluetoothService.mqttUsernameCharUuid: () => _mqttUsernameChar = char,
      RealBluetoothService.mqttPasswordCharUuid: () => _mqttPasswordChar = char,
      RealBluetoothService.configStatusCharUuid: () => _configStatusChar = char,
      RealBluetoothService.deviceIdCharUuid: () => _deviceIdChar = char,
      RealBluetoothService.ipAddressCharUuid: () => _ipAddressChar = char,
      RealBluetoothService.serverIdCharUuid: () => _serverIdChar = char,
      RealBluetoothService.wifiNetworksCharUuid: () => _wifiNetworksChar = char,
      RealBluetoothService.pinCharUuid: () => _pinChar = char,
    };

    bool found = false;
    for (final entry in mapping.entries) {
      if (uuid == entry.key.toLowerCase()) {
        entry.value();
        _log('Mapped characteristic: $uuid');
        found = true;
        break;
      }
    }
    if (!found) {
      _log('Unknown characteristic: $uuid');
    }
  }

  @override
  Future<bool> isConnected() async => device.isConnected;

  @override
  Future<void> send(String message) async {
    if (message.startsWith('PIN:')) {
      await _pinChar?.write(
        utf8.encode(message.substring(4)),
        withoutResponse: false,
      );
    } else if (message.startsWith('WIFI:')) {
      final parts = message.substring(5).split(':');
      if (parts.length >= 2) {
        await _wifiSsidChar?.write(
          utf8.encode(parts[0]),
          withoutResponse: false,
        );
        await _wifiPassChar?.write(
          utf8.encode(parts.sublist(1).join(':')),
          withoutResponse: false,
        );
      }
    } else if (message.startsWith('MQTT:')) {
      final parts = message.substring(5).split(':');
      if (parts.isNotEmpty) {
        await _mqttHostChar?.write(
          utf8.encode(parts[0]),
          withoutResponse: false,
        );
        if (parts.length > 1) {
          await _mqttPortChar?.write(
            utf8.encode(parts[1]),
            withoutResponse: false,
          );
        }
      }
    }
  }

  @override
  Future<String?> recv({Duration? timeout}) async {
    try {
      return await _messageController.stream.first.timeout(
        timeout ?? const Duration(seconds: 30),
      );
    } catch (_) {
      try {
        if (_configStatusChar != null) {
          final value = await _configStatusChar!.read();
          final status = utf8.decode(value);
          if (status.isNotEmpty &&
              status != 'READY' &&
              status != 'AWAITING_CONFIG') {
            return status;
          }
        }
      } catch (_) {}
      return null;
    }
  }

  Future<String?> _pollStatus(
    Duration timeout,
    bool Function(String) predicate,
  ) async {
    final endTime = DateTime.now().add(timeout);

    try {
      final result = await _messageController.stream
          .where(predicate)
          .first
          .timeout(const Duration(seconds: 5));
      return result;
    } catch (_) {}

    while (DateTime.now().isBefore(endTime)) {
      try {
        if (_configStatusChar != null) {
          final status = utf8.decode(await _configStatusChar!.read());
          if (predicate(status)) return status;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  Future<String?> waitForWifiResult({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return _pollStatus(
      timeout,
      (s) => s == 'WIFI_CONFIGURED' || s == 'WIFI_FAILED',
    );
  }

  Future<bool> waitForPaired({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final result = await _pollStatus(timeout, (s) => s == 'PAIRED');
    return result == 'PAIRED';
  }

  Future<bool> sendPin(String pin) async {
    if (_pinChar == null) return false;
    try {
      await _pinChar!.write(utf8.encode(pin), withoutResponse: false);
      return true;
    } catch (e) {
      _log('sendPin error: $e');
      return false;
    }
  }

  Future<String?> waitForPinResult({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Also accept states that indicate PIN was successful and ESP moved on
    return _pollStatus(
      timeout,
      (s) =>
          s == 'PIN_OK' ||
          s == 'PIN_INVALID' ||
          s == 'AWAITING_WIFI' ||
          s == 'WIFI_CONFIGURED' ||
          s == 'CONFIGURING',
    );
  }

  Future<bool> sendWifiCredentials(String ssid, String password) async {
    if (_wifiSsidChar == null || _wifiPassChar == null) return false;
    try {
      await _wifiSsidChar!.write(utf8.encode(ssid), withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 100));
      await _wifiPassChar!.write(utf8.encode(password), withoutResponse: false);
      return true;
    } catch (e) {
      _log('sendWifiCredentials error: $e');
      return false;
    }
  }

  Future<bool> sendFullMqttConfig({
    required String host,
    required int port,
    String? username,
    String? password,
  }) async {
    try {
      if (_mqttHostChar != null) {
        await _mqttHostChar!.write(utf8.encode(host), withoutResponse: false);
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_mqttPortChar != null) {
        await _mqttPortChar!.write(
          utf8.encode(port.toString()),
          withoutResponse: false,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (username != null &&
          username.isNotEmpty &&
          _mqttUsernameChar != null) {
        await _mqttUsernameChar!.write(
          utf8.encode(username),
          withoutResponse: false,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (password != null &&
          password.isNotEmpty &&
          _mqttPasswordChar != null) {
        await _mqttPasswordChar!.write(
          utf8.encode(password),
          withoutResponse: false,
        );
      }
      return true;
    } catch (e) {
      _log('sendFullMqttConfig error: $e');
      return false;
    }
  }

  @override
  Future<String?> getDeviceId() async {
    _log(
      'getDeviceId: _deviceIdChar is ${_deviceIdChar == null ? "null" : "available"}',
    );
    if (_deviceIdChar == null) {
      _log(
        'getDeviceId: Device ID characteristic not found during BLE discovery',
      );
      return null;
    }
    try {
      final bytes = await _deviceIdChar!.read();
      final deviceId = utf8.decode(bytes);
      _log('getDeviceId: Read device ID = $deviceId');
      return deviceId.isNotEmpty ? deviceId : null;
    } catch (e) {
      _log('getDeviceId: Error reading characteristic: $e');
      return null;
    }
  }

  @override
  Future<String?> getIpAddress() async {
    try {
      if (_ipAddressChar != null) {
        final ip = utf8.decode(await _ipAddressChar!.read());
        return ip.isNotEmpty ? ip : null;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String?> waitForIpAddress({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final existingIp = await getIpAddress();
      if (existingIp != null && existingIp.isNotEmpty) return existingIp;

      await for (final message in _messageController.stream.timeout(timeout)) {
        if (message.startsWith('IP:')) return message.substring(3);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> sendServerId(String serverId) async {
    try {
      if (_serverIdChar != null) {
        await _serverIdChar!.write(
          utf8.encode(serverId),
          withoutResponse: false,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<String>> getAvailableWifiNetworks() async {
    try {
      if (_wifiNetworksChar != null) {
        final jsonStr = utf8.decode(await _wifiNetworksChar!.read());
        if (jsonStr.isEmpty || jsonStr == '[]') return [];
        return (json.decode(jsonStr) as List).cast<String>();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> waitForConfigResult({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final status = await recv(timeout: timeout);
    return status == 'WIFI_CONFIGURED';
  }

  Future<bool> verifyPin(String pin) async {
    if (_pinChar == null) return false;
    try {
      await _pinChar!.write(utf8.encode(pin), withoutResponse: false);
      final response = await recv(timeout: const Duration(seconds: 5));
      return response == 'PIN_OK';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _ipSubscription?.cancel();
    await _messageController.close();
    await device.disconnect();
  }
}
