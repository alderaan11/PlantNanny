import 'dart:math';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'devices_repository.dart';

class FakeDevicesRepository implements DevicesRepository {
  // We implement the small subset used by the app.
  final Random _rand = Random();
  final List<Device> _devices = [];

  FakeDevicesRepository() {
    // Seed with one device owned by "test-user" for development visualization
    final now = DateTime.now().toUtc();
    _devices.add(Device((b) => b
      ..deviceId = 'fake-device-1'
      ..name = 'Tomates du balcon'
      ..ownerUid = 'test-user'
      ..createdAt = now));
    _devices.add(Device((b) => b
      ..deviceId = 'fake-device-2'
      ..name = 'Basilic de cuisine'
      ..ownerUid = 'test-user'
      ..createdAt = now));
  }

  // Methods that match the DevicesRepository API
  @override
  Future<List<Device>> list() async {
    await Future.delayed(const Duration(seconds: 1));
    return _devices;
  }

  @override
  Future<Device> register(String pairingCode, {String? name}) async {
    await Future.delayed(const Duration(seconds: 1));
    final deviceId = 'esp32-${pairingCode.toLowerCase().replaceAll('-', '')}';
    final now = DateTime.now().toUtc();
    final device = Device((b) => b
      ..deviceId = deviceId
      ..name = name ?? 'Device $pairingCode'
      ..ownerUid = 'test-user'
      ..createdAt = now);
    _devices.add(device);
    return device;
  }

  @override
  Future<void> unregister(String deviceId) async {
    await Future.delayed(const Duration(seconds: 1));
    _devices.removeWhere((d) => d.deviceId == deviceId);
  }

}
