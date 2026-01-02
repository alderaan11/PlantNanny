import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'package:plant_nanny/core/api_client_provider.dart';

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  return DevicesRepository(ref.watch(apiClientProvider).getDevicesApi());
});

class DevicesRepository {
  DevicesRepository(this._api);
  final DevicesApi _api;

  Future<List<Device>> list() async {
    final res = await _api.handlersV1DevicesGet();
    return res.data?.items.toList() ?? [];
  }

  Future<Device> register(String pairingCode, {String? name}) async {
    final res = await _api.handlersV1DevicesRegisterPost(
      registerDeviceRequest: RegisterDeviceRequest((b) {
        b.pairingCode = pairingCode;
        if (name != null) b.name = name;
      }),
    );
    return res.data!;
  }

  Future<void> unregister(String deviceId) {
    return _api.handlersV1DevicesDeviceIdUnregisterPost(deviceId: deviceId);
  }
}
