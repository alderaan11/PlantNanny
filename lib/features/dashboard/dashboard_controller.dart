import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/data/repositories/readings_repository.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

final dashboardProvider =
    AutoDisposeAsyncNotifierProviderFamily<DashboardController, Reading, String>(
      DashboardController.new,
    );

class DashboardController extends AutoDisposeFamilyAsyncNotifier<Reading, String> {
  Timer? _timer;

  @override
  Future<Reading> build(String deviceId) async {
    // Start periodic refresh only while being watched
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    
    return ref.read(readingsRepositoryProvider).last(deviceId);
  }
  
  Future<void> _refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(readingsRepositoryProvider).last(arg),
    );
  }
  
  /// Manually trigger a refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    await _refresh();
  }
}
