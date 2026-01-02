import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'package:plant_nanny/core/api_client_provider.dart';

/// Abstract interface so we can swap the real implementation for a fake in dev.
abstract class ReadingsRepository {
  Future<Reading> last(String deviceId);
  Future<List<Reading>> history(String deviceId, {int limit = 200});
}

final readingsRepositoryProvider = Provider<ReadingsRepository>((ref) {
  return _ReadingsRepositoryImpl(ref.watch(apiClientProvider).getReadingsApi());
});

class _ReadingsRepositoryImpl implements ReadingsRepository {
  _ReadingsRepositoryImpl(this._api);
  final ReadingsApi _api;

  @override
  Future<Reading> last(String deviceId) async {
    final res = await _api.handlersV1DevicesReadingsLastGet(deviceId: deviceId);
    return res.data!;
  }

  @override
  Future<List<Reading>> history(String deviceId, {int limit = 200}) async {
    final res = await _api.handlersV1DevicesReadingsGet(
      deviceId: deviceId,
      limit: limit,
      order: 'desc',
    );
    return res.data?.items.toList() ?? [];
  }
}
