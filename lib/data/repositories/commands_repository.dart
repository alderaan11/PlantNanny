import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/core/api_client_provider.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'commands_repository_base.dart';
import 'package:plant_nanny/core/api_client_provider.dart';

final commandsRepositoryProvider = Provider<CommandsRepositoryBase>((ref) {
  return CommandsRepository(ref.watch(apiClientProvider).getCommandsApi());
});

class CommandsRepository implements CommandsRepositoryBase {
  CommandsRepository(this._api);
  final CommandsApi _api;

  @override
  Future<void> forceReading(String deviceId) {
    return _api.handlersV1DevicesCommandsPost(
      deviceId: deviceId,
      commandIn: CommandIn((CommandInBuilder b) {
        b.type = CommandType.forceReading;
      }),
    );
  }

  @override
  Future<void> pump(String deviceId, int durationSec) {
    return _api.handlersV1DevicesCommandsPost(
      deviceId: deviceId,
      commandIn: CommandIn((CommandInBuilder b) {
        b.type = CommandType.pumpWater;
        b.durationMs = durationSec * 1000; // Convertir secondes en millisecondes pour l'API
      }),
    );
  }
}
