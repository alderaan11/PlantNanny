import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_metadata_provider.dart';
import 'global_settings_provider.dart';

class PerDevicePumpNotifier extends StateNotifier<Map<String, int>> {
  PerDevicePumpNotifier(this.ref) : super({});
  final Ref ref;

  int getDurationFor(String deviceId) {
    final explicit = state[deviceId];
    if (explicit != null) return explicit;
    final meta = ref.read(deviceMetadataProvider)[deviceId];
    if (meta != null && meta.baseDoseSec != null) return meta.baseDoseSec;
    return ref.read(globalPumpDurationProvider);
  }

  void setDurationFor(String deviceId, int sec) {
    state = {...state, deviceId: sec};
  }
}

final perDevicePumpDurationProvider = StateNotifierProvider<PerDevicePumpNotifier, Map<String, int>>((ref) {
  return PerDevicePumpNotifier(ref);
});
