import 'dart:math';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'readings_repository.dart';

class FakeReadingsRepository implements ReadingsRepository {
  final Random _rand = Random();

  double _rnd(double base, double variance) =>
      base + (_rand.nextDouble() - 0.5) * variance * 2;

  Reading _randomReading({
    required String deviceId,
    required DateTime ts,
    String? id,
  }) {
    final t = _rnd(22.0, 4.0);
    final h = _rnd(55.0, 20.0);
    final l = _rnd(50.0, 50.0);

    return Reading((ReadingBuilder b) {
      b.id = id ?? 'fake_${deviceId}_${ts.millisecondsSinceEpoch}';
      b.deviceId = deviceId;
      b.ts = ts.toUtc();

      // Champs num
      b.temperatureC = double.parse(t.toStringAsFixed(2));
      b.humidityPct = double.parse(h.toStringAsFixed(2));
      b.luminosityPct = double.parse(l.toStringAsFixed(2));
    });
  }

  @override
  Future<Reading> last(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _randomReading(
      deviceId: deviceId,
      ts: DateTime.now(),
    );
  }

  @override
  Future<List<Reading>> history(String deviceId, {int limit = 200}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final count = min(limit, 60);

    return List.generate(count, (i) {
      return _randomReading(
        deviceId: deviceId,
        ts: now.subtract(Duration(minutes: i)),
        id: 'fake_${deviceId}_$i',
      );
    });
  }
}
