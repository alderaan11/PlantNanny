import 'dart:convert';
import '../core/bluetooth_service.dart';

/// Sends wifi SSID and password as a JSON object to the device over bluetooth.
/// The device must accept a UTF-8 JSON payload with keys `ssid` and `password`.
Future<bool> sendWifiCredentials(BluetoothEndpoint endpoint, String ssid, String password) async {
  final payload = jsonEncode({'ssid': ssid, 'password': password});
  try {
    if (!await endpoint.isConnected()) {
      final ok = await endpoint.connect();
      if (!ok) return false;
    }

    await endpoint.send(payload);

    // Optionally wait for a response acknowledging success.
    final resp = await endpoint.recv(timeout: Duration(seconds: 5));
    if (resp == null) return true; // no response required

    // Basic handshake: device may reply with 'OK' or JSON {status: 'ok'}
    if (resp.trim().toLowerCase().contains('ok') || resp.contains('"status"')) return true;
    return false;
  } catch (_) {
    return false;
  }
}
