import 'package:flutter_test/flutter_test.dart';
import 'package:plant_nanny/features/devices/device_setup_provider.dart';
import 'package:plant_nanny/features/devices/fake_bluetooth_service.dart';
import 'package:plant_nanny/core/bluetooth_service.dart';
import 'package:plant_nanny/core/uuid_utils.dart';

void main() {
  group('UUID Format Validation', () {
    test('FakeBluetoothEndpoint returns proper UUID v4 format', () async {
      final endpoint = FakeBluetoothEndpoint(
        id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        name: 'PlantNanny-001',
      );

      final deviceId = await endpoint.getDeviceId();

      expect(deviceId, isNotNull);
      expect(deviceId!.length, equals(36), reason: 'UUID should be 36 characters');
      expect(
        RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(deviceId),
        isTrue,
        reason: 'Device ID should be a valid UUID v4 format',
      );
    });

    test('Device ID should NOT use legacy esp32-MAC format', () async {
      final endpoint = FakeBluetoothEndpoint(
        id: 'a1b2c3d4-e5f6-4789-abcd-ef0123456789',
        name: 'PlantNanny-002',
      );

      final deviceId = await endpoint.getDeviceId();

      expect(deviceId, isNotNull);
      expect(
        deviceId!.startsWith('esp32-'),
        isFalse,
        reason: 'Device ID should not use legacy esp32-MAC format',
      );
      expect(
        deviceId.length,
        equals(36),
        reason: 'UUID should be 36 characters, not legacy format',
      );
    });

    test('FakeBluetoothService returns endpoints with valid UUIDs', () async {
      final service = FakeBluetoothService();
      final endpoints = await service.findNearEndpoints();

      expect(endpoints, isNotEmpty);

      for (final endpoint in endpoints) {
        final deviceId = await endpoint.getDeviceId();
        expect(deviceId, isNotNull, reason: 'Each endpoint should have a device ID');
        expect(deviceId!.length, equals(36), reason: 'Device ID should be UUID format (36 chars)');
        expect(
          deviceId.startsWith('esp32-'),
          isFalse,
          reason: 'Device ID should not use legacy format',
        );
      }
    });
  });

  group('DeviceSetupModel', () {
    test('cachedDeviceId field exists and is nullable', () {
      final model = DeviceSetupModel();
      expect(model.cachedDeviceId, isNull);
    });

    test('cachedDeviceId can be set via copyWith', () {
      final model = DeviceSetupModel();
      final uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

      final updated = model.copyWith(cachedDeviceId: uuid);

      expect(updated.cachedDeviceId, equals(uuid));
      expect(updated.cachedDeviceId!.length, equals(36));
    });

    test('cachedDeviceId is preserved across state transitions', () {
      final uuid = 'a1b2c3d4-e5f6-4789-abcd-ef0123456789';
      final model = DeviceSetupModel(
        state: DeviceSetupState.enterPin,
        cachedDeviceId: uuid,
      );

      // Transition to next state
      final selectWifi = model.copyWith(state: DeviceSetupState.selectWifi);
      expect(selectWifi.cachedDeviceId, equals(uuid));

      // Transition to waiting state
      final waiting = selectWifi.copyWith(state: DeviceSetupState.waitingWifi);
      expect(waiting.cachedDeviceId, equals(uuid));

      // Transition to success state
      final success = waiting.copyWith(state: DeviceSetupState.success);
      expect(success.cachedDeviceId, equals(uuid));
    });

    test('registeredDeviceId stores the final device ID after registration', () {
      final uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      final model = DeviceSetupModel(
        state: DeviceSetupState.success,
        cachedDeviceId: uuid,
        registeredDeviceId: uuid,
      );

      expect(model.registeredDeviceId, equals(uuid));
      expect(model.registeredDeviceId!.length, equals(36));
    });
  });

  group('DeviceSetupState Enum', () {
    test('all states are defined for complete flow', () {
      // Ensure all expected states exist
      expect(DeviceSetupState.values, contains(DeviceSetupState.scanning));
      expect(DeviceSetupState.values, contains(DeviceSetupState.selectDevice));
      expect(DeviceSetupState.values, contains(DeviceSetupState.connecting));
      expect(DeviceSetupState.values, contains(DeviceSetupState.enterPin));
      expect(DeviceSetupState.values, contains(DeviceSetupState.selectWifi));
      expect(DeviceSetupState.values, contains(DeviceSetupState.enterWifiPass));
      expect(DeviceSetupState.values, contains(DeviceSetupState.sending));
      expect(DeviceSetupState.values, contains(DeviceSetupState.waitingWifi));
      expect(DeviceSetupState.values, contains(DeviceSetupState.success));
      expect(DeviceSetupState.values, contains(DeviceSetupState.error));
      expect(DeviceSetupState.values, contains(DeviceSetupState.wifiError));
    });
  });

  group('BluetoothEndpoint Interface', () {
    test('getDeviceId returns the endpoint ID', () async {
      final endpoint = FakeBluetoothEndpoint(
        id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        name: 'TestDevice',
      );

      final deviceId = await endpoint.getDeviceId();
      expect(deviceId, equals(endpoint.id));
    });

    test('getIpAddress requires connection', () async {
      final endpoint = FakeBluetoothEndpoint(
        id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        name: 'TestDevice',
      );

      // Not connected yet
      final ipBefore = await endpoint.getIpAddress();
      expect(ipBefore, isNull);

      // Connect
      await endpoint.connect();

      // Now should have IP
      final ipAfter = await endpoint.getIpAddress();
      expect(ipAfter, isNotNull);
      expect(ipAfter, contains('.'), reason: 'IP address should contain dots');
    });
  });

  group('UUID Helper Functions', () {
    test('isValidUuid validates correct UUID v4 format', () {
      expect(isValidUuid('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isTrue);
      expect(isValidUuid('a1b2c3d4-e5f6-4789-abcd-ef0123456789'), isTrue);
      expect(isValidUuid('550e8400-e29b-41d4-a716-446655440000'), isTrue);
    });

    test('isValidUuid rejects legacy esp32-MAC format', () {
      expect(isValidUuid('esp32-esp32a456c9b994924970a10997662265a0df'), isFalse);
      expect(isValidUuid('esp32-abcdef123456'), isFalse);
    });

    test('isValidUuid rejects invalid formats', () {
      expect(isValidUuid(''), isFalse);
      expect(isValidUuid('not-a-uuid'), isFalse);
      expect(isValidUuid('12345678-1234-1234-1234-123456789'), isFalse); // Too short
      expect(isValidUuid('12345678-1234-1234-1234-1234567890123'), isFalse); // Too long
      expect(isValidUuid('12345678123412341234123456789012'), isFalse); // No dashes
    });

    test('isValidUuid rejects null-like values', () {
      expect(isValidUuid('null'), isFalse);
      expect(isValidUuid('undefined'), isFalse);
    });

    test('isLegacyDeviceId detects legacy format', () {
      expect(isLegacyDeviceId('esp32-esp32a456c9b994924970a10997662265a0df'), isTrue);
      expect(isLegacyDeviceId('esp32-abcdef123456'), isTrue);
      expect(isLegacyDeviceId('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isFalse);
      expect(isLegacyDeviceId(''), isFalse);
    });

    test('isValidDeviceId validates correctly', () {
      // Valid UUIDs should pass
      expect(isValidDeviceId('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isTrue);
      expect(isValidDeviceId('a1b2c3d4-e5f6-4789-abcd-ef0123456789'), isTrue);
      
      // Legacy format should fail
      expect(isValidDeviceId('esp32-esp32a456c9b994924970a10997662265a0df'), isFalse);
      
      // Invalid formats should fail
      expect(isValidDeviceId(''), isFalse);
      expect(isValidDeviceId('not-valid'), isFalse);
    });

    test('String extension methods work correctly', () {
      const validUuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      const legacyId = 'esp32-abcdef123456';
      
      expect(validUuid.isUuid, isTrue);
      expect(validUuid.isValidDeviceId, isTrue);
      expect(validUuid.isLegacyDeviceId, isFalse);
      
      expect(legacyId.isUuid, isFalse);
      expect(legacyId.isValidDeviceId, isFalse);
      expect(legacyId.isLegacyDeviceId, isTrue);
    });
  });
}
