abstract class CommandsRepositoryBase {
  Future<void> forceReading(String deviceId);
  Future<void> pump(String deviceId, int durationSec);
}
