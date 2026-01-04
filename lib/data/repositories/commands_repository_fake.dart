import 'dart:async';
import 'commands_repository_base.dart';

class FakeCommandsRepository implements CommandsRepositoryBase {
  FakeCommandsRepository();

  @override
  Future<void> forceReading(String deviceId) async {
    // Simulate network delay and success
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real fake we could add entries to a local commands store for UI, omitted for brevity
    return;
  }

  @override
  Future<void> pump(String deviceId, int durationMs) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return;
  }
}
