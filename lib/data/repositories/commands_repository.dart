import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import '../../core/api_client_provider.dart';

final commandsRepositoryProvider = Provider<CommandsRepository>((ref) {
  return CommandsRepository(CommandsApi(ref.watch(apiClientProvider)));
});

class CommandsRepository {
  CommandsRepository(this._api);
  final CommandsApi _api;

  Future<void> forceReading(String deviceId) {
    return _api.v1DevicesDeviceIdCommandsPost(
      deviceId,
      commandIn: CommandIn(type: CommandType.forceReading),
    );
  }

  Future<void> pump(String deviceId, int durationMs) {
    return _api.v1DevicesDeviceIdCommandsPost(
      deviceId,
      commandIn: CommandIn(type: CommandType.pumpWater, durationMs: durationMs),
    );
  }
}
