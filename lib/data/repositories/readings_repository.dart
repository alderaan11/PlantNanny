import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'package:plant_nanny/core/api_client_provider.dart';

final readingsRepositoryProvider = Provider<ReadingsRepository>((ref) {
  return ReadingsRepository(ref.watch(apiClientProvider).getReadingsApi());
});

class ReadingsRepository {
  ReadingsRepository(this._api);
  final ReadingsApi _api;

  Future<Reading> last(String deviceId) async {
    final res = await _api.handlersV1DevicesReadingsLastGet(deviceId: deviceId);
    return res.data!;
  }

  Future<List<Reading>> history(String deviceId, {int limit = 200}) async {
    final res = await _api.handlersV1DevicesReadingsGet(
      deviceId: deviceId,
      limit: limit,
      order: 'desc',
    );
    return res.data?.items.toList() ?? [];
  }
}
