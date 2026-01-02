import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/readings_repository.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

final dashboardProvider =
    AsyncNotifierProviderFamily<DashboardController, Reading, String>(
  DashboardController.new,
);

class DashboardController extends FamilyAsyncNotifier<Reading, String> {
  Timer? _timer;

  @override
  Future<Reading> build(String deviceId) async {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      state = await AsyncValue.guard(
        () => ref.read(readingsRepositoryProvider).last(deviceId),
      );
    });

    ref.onDispose(() => _timer?.cancel());
    return ref.read(readingsRepositoryProvider).last(deviceId);
  }
}
