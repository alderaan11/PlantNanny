import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'package:plant_nanny/core/api_client_provider.dart';

final commandsRepositoryProvider = Provider<CommandsRepository>((ref) {
  return CommandsRepository(ref.watch(apiClientProvider).getCommandsApi());
});

class CommandsRepository {
  CommandsRepository(this._api);
  final CommandsApi _api;

  Future<void> forceReading(String deviceId) {
    return _api.handlersV1DevicesCommandsPost(
      deviceId: deviceId,
      commandIn: CommandIn((b) {
        b.type = CommandType.forceReading;
      }),
    );
  }

  Future<void> pump(String deviceId, int durationMs) {
    return _api.handlersV1DevicesCommandsPost(
      deviceId: deviceId,
      commandIn: CommandIn((b) {
        b.type = CommandType.pumpWater;
        b.durationMs = durationMs;
      }),
    );
  }
}
