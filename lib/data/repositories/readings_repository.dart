import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import '../../core/api_client_provider.dart';

final readingsRepositoryProvider = Provider<ReadingsRepository>((ref) {
  return ReadingsRepository(ReadingsApi(ref.watch(apiClientProvider)));
});

class ReadingsRepository {
  ReadingsRepository(this._api);
  final ReadingsApi _api;

  Future<Reading> last(String deviceId) {
    return _api.v1DevicesDeviceIdReadingsLastGet(deviceId);
  }

  Future<List<Reading>> history(String deviceId, {int limit = 200}) async {
    final res = await _api.v1DevicesDeviceIdReadingsGet(
      deviceId,
      limit: limit,
      order: 'desc',
    );
    return res.items ?? [];
  }
}
