import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class to handle Bluetooth permissions
class BluetoothPermissions {
  /// Request all permissions needed for BLE scanning
  static Future<bool> requestPermissions() async {
    // Skip on non-mobile platforms
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return await _requestiOSPermissions();
    }

    return true;
  }

  static Future<bool> _requestAndroidPermissions() async {
    // For Android 12+ (API 31+), we need BLUETOOTH_SCAN and BLUETOOTH_CONNECT
    // For older versions, we need location permissions

    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    // Request all permissions
    final statuses = await permissions.request();

    // Check if Bluetooth permissions are granted
    final bluetoothScanGranted =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final bluetoothConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final locationGranted =
        statuses[Permission.locationWhenInUse]?.isGranted ?? false;

    if (kDebugMode) {
      print('[Permissions] bluetoothScan: $bluetoothScanGranted');
      print('[Permissions] bluetoothConnect: $bluetoothConnectGranted');
      print('[Permissions] location: $locationGranted');
    }

    // On Android 12+, we need at least bluetoothScan
    // On older Android, we need location
    return (bluetoothScanGranted && bluetoothConnectGranted) || locationGranted;
  }

  static Future<bool> _requestiOSPermissions() async {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> checkPermissions() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    if (Platform.isAndroid) {
      final bluetoothScan = await Permission.bluetoothScan.isGranted;
      final bluetoothConnect = await Permission.bluetoothConnect.isGranted;
      final location = await Permission.locationWhenInUse.isGranted;

      return (bluetoothScan && bluetoothConnect) || location;
    } else if (Platform.isIOS) {
      return await Permission.bluetooth.isGranted;
    }

    return true;
  }

  /// Open app settings so user can grant permissions manually
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
