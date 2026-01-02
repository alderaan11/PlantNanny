import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import '../../core/api_client_provider.dart';

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  return DevicesRepository(DevicesApi(ref.watch(apiClientProvider)));
});

class DevicesRepository {
  DevicesRepository(this._api);
  final DevicesApi _api;

  Future<List<Device>> list() async {
    final res = await _api.v1DevicesGet();
    return res.items ?? [];
  }

  Future<Device> register(String pairingCode, {String? name}) {
    return _api.v1DevicesRegisterPost(
      registerDeviceRequest: RegisterDeviceRequest(
        pairingCode: pairingCode,
        name: name,
      ),
    );
  }

  Future<void> unregister(String deviceId) {
    return _api.v1DevicesDeviceIdUnregisterPost(deviceId);
  }
}
