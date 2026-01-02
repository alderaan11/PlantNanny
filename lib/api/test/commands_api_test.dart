import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for CommandsApi
void main() {
  final instance = PlantNannyApi().getCommandsApi();

  group(CommandsApi, () {
    // ESP32 acknowledges command execution result
    //
    //Future<Command> v1DevicesDeviceIdCommandsCommandIdAckPost(String deviceId, String commandId, CommandAck commandAck) async
    test('test v1DevicesDeviceIdCommandsCommandIdAckPost', () async {
      // TODO
    });

    // List commands (for UI history/debug)
    //
    //Future<CommandList> v1DevicesDeviceIdCommandsGet(String deviceId, { int limit }) async
    test('test v1DevicesDeviceIdCommandsGet', () async {
      // TODO
    });

    // ESP32 polls pending commands
    //
    //Future<CommandList> v1DevicesDeviceIdCommandsPendingGet(String deviceId, { int max }) async
    test('test v1DevicesDeviceIdCommandsPendingGet', () async {
      // TODO
    });

    // Create a command for a device (force reading, pump, etc.)
    //
    //Future<Command> v1DevicesDeviceIdCommandsPost(String deviceId, CommandIn commandIn) async
    test('test v1DevicesDeviceIdCommandsPost', () async {
      // TODO
    });

  });
}
