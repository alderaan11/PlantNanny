import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../../core/bluetooth_service.dart' as core;

/// Real Bluetooth service using flutter_blue_plus
class RealBluetoothService extends core.BluetoothService {
  static const String configServiceUuid = '12345678-1234-5678-1234-56789abcdef0';
  static const String wifiSsidCharUuid = '12345678-1234-5678-1234-56789abcdef1';
  static const String wifiPassCharUuid = '12345678-1234-5678-1234-56789abcdef2';
  static const String mqttHostCharUuid = '12345678-1234-5678-1234-56789abcdef3';
  static const String mqttPortCharUuid = '12345678-1234-5678-1234-56789abcdef4';
  static const String configStatusCharUuid = '12345678-1234-5678-1234-56789abcdef5';
  static const String deviceIdCharUuid = '12345678-1234-5678-1234-56789abcdef6';
  static const String ipAddressCharUuid = '12345678-1234-5678-1234-56789abcdef7';
  static const String serverIdCharUuid = '12345678-1234-5678-1234-56789abcdef8';
  static const String wifiNetworksCharUuid = '12345678-1234-5678-1234-56789abcdef9';
  static const String pinCharUuid = '12345678-1234-5678-1234-56789abcdefa';

  @override
  Future<List<core.BluetoothEndpoint>> findNearEndpoints() async {
    final List<core.BluetoothEndpoint> endpoints = [];
    
    // Check if Bluetooth is on
    if (await fbp.FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth not supported on this device');
    }

    // Turn on Bluetooth if not already on (Android only)
    if (await fbp.FlutterBluePlus.adapterState.first != fbp.BluetoothAdapterState.on) {
      // Wait for Bluetooth to be turned on
      await fbp.FlutterBluePlus.adapterState
          .where((state) => state == fbp.BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Bluetooth is not enabled');
      });
    }

    // Start scanning
    await fbp.FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      withServices: [fbp.Guid(configServiceUuid)],
    );

    // Listen to scan results
    final subscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        // Filter for PlantNanny devices
        final name = result.device.platformName;
        if (name.toLowerCase().contains('plantnanny') ||
            result.advertisementData.serviceUuids.any(
              (uuid) => uuid.toString().toLowerCase() == configServiceUuid.toLowerCase(),
            )) {
          final existing = endpoints.where((e) => e.id == result.device.remoteId.str);
          if (existing.isEmpty) {
            endpoints.add(RealBluetoothEndpoint(
              device: result.device,
              deviceName: name.isNotEmpty ? name : 'PlantNanny Device',
            ));
          }
        }
      }
    });

    // Wait for scan to complete
    await Future.delayed(const Duration(seconds: 10));
    await fbp.FlutterBluePlus.stopScan();
    await subscription.cancel();

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

/// Real Bluetooth endpoint using flutter_blue_plus
class RealBluetoothEndpoint implements core.BluetoothEndpoint {
  final fbp.BluetoothDevice device;
  final String _name;
  
  fbp.BluetoothCharacteristic? _wifiSsidChar;
  fbp.BluetoothCharacteristic? _wifiPassChar;
  fbp.BluetoothCharacteristic? _mqttHostChar;
  fbp.BluetoothCharacteristic? _mqttPortChar;
  fbp.BluetoothCharacteristic? _configStatusChar;
  fbp.BluetoothCharacteristic? _deviceIdChar;
  fbp.BluetoothCharacteristic? _ipAddressChar;
  fbp.BluetoothCharacteristic? _serverIdChar;
  fbp.BluetoothCharacteristic? _wifiNetworksChar;
  fbp.BluetoothCharacteristic? _pinChar;
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _ipSubscription;
  final StreamController<String> _messageController = StreamController.broadcast();

  RealBluetoothEndpoint({required this.device, String? deviceName}) : _name = deviceName ?? 'Unknown';

  @override
  String get id => device.remoteId.str;

  @override
  String? get name => _name;

  @override
  Future<bool> connect() async {
    try {
      await device.connect(license: fbp.License.free, timeout: const Duration(seconds: 15));
      
      // Wait for connection to stabilize
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find our config service
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == 
            RealBluetoothService.configServiceUuid.toLowerCase()) {
          for (final char in service.characteristics) {
            final charUuid = char.uuid.toString().toLowerCase();
            
            if (charUuid == RealBluetoothService.wifiSsidCharUuid.toLowerCase()) {
              _wifiSsidChar = char;
            } else if (charUuid == RealBluetoothService.wifiPassCharUuid.toLowerCase()) {
              _wifiPassChar = char;
            } else if (charUuid == RealBluetoothService.mqttHostCharUuid.toLowerCase()) {
              _mqttHostChar = char;
            } else if (charUuid == RealBluetoothService.mqttPortCharUuid.toLowerCase()) {
              _mqttPortChar = char;
            } else if (charUuid == RealBluetoothService.configStatusCharUuid.toLowerCase()) {
              _configStatusChar = char;
            } else if (charUuid == RealBluetoothService.deviceIdCharUuid.toLowerCase()) {
              _deviceIdChar = char;
            } else if (charUuid == RealBluetoothService.ipAddressCharUuid.toLowerCase()) {
              _ipAddressChar = char;
            } else if (charUuid == RealBluetoothService.serverIdCharUuid.toLowerCase()) {
              _serverIdChar = char;
            } else if (charUuid == RealBluetoothService.wifiNetworksCharUuid.toLowerCase()) {
              _wifiNetworksChar = char;
            } else if (charUuid == RealBluetoothService.pinCharUuid.toLowerCase()) {
              _pinChar = char;
            }
          }
        }
      }

      // Subscribe to status notifications
      if (_configStatusChar != null) {
        await _configStatusChar!.setNotifyValue(true);
        _statusSubscription = _configStatusChar!.onValueReceived.listen((value) {
          final status = utf8.decode(value);
          _messageController.add(status);
        });
      }

      // Subscribe to IP address notifications
      if (_ipAddressChar != null) {
        await _ipAddressChar!.setNotifyValue(true);
        _ipSubscription = _ipAddressChar!.onValueReceived.listen((value) {
          final ip = utf8.decode(value);
          if (ip.isNotEmpty) {
            _messageController.add('IP:$ip');
          }
        });
      }

      return _wifiSsidChar != null && _wifiPassChar != null;
    } catch (e) {
      print('BLE connect error: $e');
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    return device.isConnected;
  }

  @override
  Future<void> send(String message) async {
    // Parse the message to determine what to send
    // Format: "WIFI:ssid:password" or "MQTT:host:port" or "PIN:123456"
    
    if (message.startsWith('PIN:')) {
      // Send PIN to the device for verification
      final pin = message.substring(4);
      if (_pinChar != null) {
        await _pinChar!.write(utf8.encode(pin), withoutResponse: false);
      }
      return;
    }
    
    if (message.startsWith('WIFI:')) {
      final parts = message.substring(5).split(':');
      if (parts.length >= 2) {
        final ssid = parts[0];
        final password = parts.sublist(1).join(':'); // Password might contain ':'
        
        // Write SSID
        if (_wifiSsidChar != null) {
          await _wifiSsidChar!.write(utf8.encode(ssid), withoutResponse: false);
        }
        
        // Write password (this triggers the config on ESP32)
        if (_wifiPassChar != null) {
          await _wifiPassChar!.write(utf8.encode(password), withoutResponse: false);
        }
      }
      return;
    }
    
    if (message.startsWith('MQTT:')) {
      final parts = message.substring(5).split(':');
      if (parts.isNotEmpty) {
        final host = parts[0];
        final port = parts.length > 1 ? parts[1] : '1883';
        
        if (_mqttHostChar != null) {
          await _mqttHostChar!.write(utf8.encode(host), withoutResponse: false);
        }
        if (_mqttPortChar != null) {
          await _mqttPortChar!.write(utf8.encode(port), withoutResponse: false);
        }
      }
      return;
    }
  }

  @override
  Future<String?> recv({Duration? timeout}) async {
    try {
      final message = await _messageController.stream.first
          .timeout(timeout ?? const Duration(seconds: 30));
      return message;
    } catch (e) {
      // Timeout or error - try to read status directly as fallback
      try {
        if (_configStatusChar != null) {
          final value = await _configStatusChar!.read();
          final status = utf8.decode(value);
          if (status.isNotEmpty && status != 'READY' && status != 'AWAITING_CONFIG') {
            return status;
          }
        }
      } catch (_) {}
      return null;
    }
  }

  /// Wait for WiFi result with polling fallback
  Future<String?> waitForWifiResult({Duration timeout = const Duration(seconds: 30)}) async {
    final endTime = DateTime.now().add(timeout);
    
    // First try to get from stream
    try {
      final streamFuture = _messageController.stream
          .where((msg) => msg == 'WIFI_CONFIGURED' || msg == 'WIFI_FAILED')
          .first
          .timeout(const Duration(seconds: 5));
      
      final result = await streamFuture;
      return result;
    } catch (_) {
      // Stream timeout, fall back to polling
    }
    
    // Poll the status characteristic
    while (DateTime.now().isBefore(endTime)) {
      try {
        if (_configStatusChar != null) {
          final value = await _configStatusChar!.read();
          final status = utf8.decode(value);
          if (status == 'WIFI_CONFIGURED' || status == 'WIFI_FAILED') {
            return status;
          }
        }
      } catch (e) {
        print('Error polling status: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    
    return null;
  }

  /// Wait for pairing completion (PAIRED status from ESP32)
  Future<bool> waitForPaired({Duration timeout = const Duration(seconds: 30)}) async {
    final endTime = DateTime.now().add(timeout);
    
    // First try to get from stream
    try {
      final streamFuture = _messageController.stream
          .where((msg) => msg == 'PAIRED')
          .first
          .timeout(const Duration(seconds: 5));
      
      await streamFuture;
      return true;
    } catch (_) {
      // Stream timeout, fall back to polling
    }
    
    // Poll the status characteristic
    while (DateTime.now().isBefore(endTime)) {
      try {
        if (_configStatusChar != null) {
          final value = await _configStatusChar!.read();
          final status = utf8.decode(value);
          if (status == 'PAIRED') {
            return true;
          }
        }
      } catch (e) {
        print('Error polling paired status: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    
    return false;
  }

  /// Send WiFi credentials directly (preferred method)
  Future<bool> sendWifiCredentials(String ssid, String password) async {
    try {
      if (_wifiSsidChar == null || _wifiPassChar == null) {
        return false;
      }

      // Write SSID first
      await _wifiSsidChar!.write(utf8.encode(ssid), withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Write password (this triggers the config on ESP32)
      await _wifiPassChar!.write(utf8.encode(password), withoutResponse: false);
      
      return true;
    } catch (e) {
      print('Error sending WiFi credentials: $e');
      return false;
    }
  }

  /// Send MQTT configuration
  Future<bool> sendMqttConfig(String host, int port) async {
    try {
      if (_mqttHostChar != null) {
        await _mqttHostChar!.write(utf8.encode(host), withoutResponse: false);
      }
      if (_mqttPortChar != null) {
        await _mqttPortChar!.write(utf8.encode(port.toString()), withoutResponse: false);
      }
      return true;
    } catch (e) {
      print('Error sending MQTT config: $e');
      return false;
    }
  }

  /// Get device ID from the ESP32
  Future<String?> getDeviceId() async {
    try {
      if (_deviceIdChar != null) {
        final value = await _deviceIdChar!.read();
        return utf8.decode(value);
      }
      return null;
    } catch (e) {
      print('Error reading device ID: $e');
      return null;
    }
  }

  /// Get the ESP32's IP address (available after WiFi connects)
  Future<String?> getIpAddress() async {
    try {
      if (_ipAddressChar != null) {
        final value = await _ipAddressChar!.read();
        final ip = utf8.decode(value);
        return ip.isNotEmpty ? ip : null;
      }
      return null;
    } catch (e) {
      print('Error reading IP address: $e');
      return null;
    }
  }

  /// Wait for IP address notification (after WiFi connects)
  Future<String?> waitForIpAddress({Duration timeout = const Duration(seconds: 30)}) async {
    try {
      // First check if IP is already available
      final existingIp = await getIpAddress();
      if (existingIp != null && existingIp.isNotEmpty) {
        return existingIp;
      }
      
      // Wait for notification
      await for (final message in _messageController.stream.timeout(timeout)) {
        if (message.startsWith('IP:')) {
          return message.substring(3);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send server-assigned device ID to the ESP32
  Future<bool> sendServerId(String serverId) async {
    try {
      if (_serverIdChar != null) {
        await _serverIdChar!.write(utf8.encode(serverId), withoutResponse: false);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending server ID: $e');
      return false;
    }
  }

  /// Get list of available WiFi networks from ESP32
  Future<List<String>> getAvailableWifiNetworks() async {
    try {
      if (_wifiNetworksChar != null) {
        final value = await _wifiNetworksChar!.read();
        final jsonStr = utf8.decode(value);
        print('WiFi networks JSON: $jsonStr');
        
        if (jsonStr.isEmpty || jsonStr == '[]') {
          return [];
        }
        
        // Parse JSON array of strings
        final List<dynamic> networks = json.decode(jsonStr);
        return networks.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error reading WiFi networks: $e');
      return [];
    }
  }

  /// Wait for configuration result
  Future<bool> waitForConfigResult({Duration timeout = const Duration(seconds: 30)}) async {
    try {
      final status = await recv(timeout: timeout);
      return status == 'WIFI_CONFIGURED';
    } catch (e) {
      return false;
    }
  }

  /// Verify PIN with the device
  /// Returns true if PIN is valid, false otherwise
  Future<bool> verifyPin(String pin) async {
    try {
      if (_pinChar == null) {
        print('PIN characteristic not found');
        return false;
      }
      
      // Write PIN to the characteristic
      await _pinChar!.write(utf8.encode(pin), withoutResponse: false);
      
      // Wait for response via status characteristic
      final response = await recv(timeout: const Duration(seconds: 5));
      print('PIN verification response: $response');
      
      return response == 'PIN_OK';
    } catch (e) {
      print('Error verifying PIN: $e');
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
