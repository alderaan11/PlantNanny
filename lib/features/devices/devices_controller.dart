import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/data/repositories/devices_repository.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

final devicesControllerProvider =
    AsyncNotifierProvider<DevicesController, List<Device>>(
      DevicesController.new,
    );

class DevicesController extends AsyncNotifier<List<Device>> {
  Timer? _timer;

  @override
  Future<List<Device>> build() {
    // Keep alive to maintain periodic updates
    ref.keepAlive();
    
    // Refresh device list every 30 seconds
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    
    return ref.read(devicesRepositoryProvider).list();
  }
  
  Future<void> _refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(devicesRepositoryProvider).list(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await _refresh();
  }
}
