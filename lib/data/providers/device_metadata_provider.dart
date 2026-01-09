import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_metadata.dart';

class DeviceMetadataNotifier extends StateNotifier<Map<String, DeviceMetadata>> {
  DeviceMetadataNotifier() : super({});

  void setMetadata(String deviceId, DeviceMetadata meta) {
    state = {...state, deviceId: meta};
  }

  DeviceMetadata? get(String deviceId) => state[deviceId];

  void remove(String deviceId) {
    final copy = {...state};
    copy.remove(deviceId);
    state = copy;
  }
}

final deviceMetadataProvider = StateNotifierProvider<DeviceMetadataNotifier, Map<String, DeviceMetadata>>((ref) {
  return DeviceMetadataNotifier();
});
