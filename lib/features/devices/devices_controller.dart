import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/data/repositories/devices_repository.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

final devicesControllerProvider =
    AsyncNotifierProvider<DevicesController, List<Device>>(
      DevicesController.new,
    );

class DevicesController extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() {
    return ref.read(devicesRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(devicesRepositoryProvider).list(),
    );
  }
}
