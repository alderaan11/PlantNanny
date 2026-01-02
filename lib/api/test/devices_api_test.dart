import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for DevicesApi
void main() {
  final instance = PlantNannyApi().getDevicesApi();

  group(DevicesApi, () {
    // Get device details
    //
    //Future<Device> v1DevicesDeviceIdGet(String deviceId) async
    test('test v1DevicesDeviceIdGet', () async {
      // TODO
    });

    // Update device (rename, metadata)
    //
    //Future<Device> v1DevicesDeviceIdPatch(String deviceId, UpdateDeviceRequest updateDeviceRequest) async
    test('test v1DevicesDeviceIdPatch', () async {
      // TODO
    });

    // Get device status (connectivity, lastSeen, firmware)
    //
    //Future<DeviceStatus> v1DevicesDeviceIdStatusGet(String deviceId) async
    test('test v1DevicesDeviceIdStatusGet', () async {
      // TODO
    });

    // Unregister device from current user
    //
    //Future v1DevicesDeviceIdUnregisterPost(String deviceId) async
    test('test v1DevicesDeviceIdUnregisterPost', () async {
      // TODO
    });

    // List devices for current user
    //
    //Future<DeviceList> v1DevicesGet() async
    test('test v1DevicesGet', () async {
      // TODO
    });

    // Register (pair) a device to the authenticated user
    //
    // Utilisé après appairage BLE/provisioning : l'app obtient un pairingCode depuis l'ESP32, puis appelle cette route pour associer le device au user. 
    //
    //Future<Device> v1DevicesRegisterPost(RegisterDeviceRequest registerDeviceRequest) async
    test('test v1DevicesRegisterPost', () async {
      // TODO
    });

  });
}
