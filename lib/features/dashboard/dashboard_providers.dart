import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/data/repositories/readings_repository.dart';

enum TimeRange { day, week, month, year }

class DashboardRequest {
  final String deviceId;
  final TimeRange range;
  const DashboardRequest({required this.deviceId, required this.range});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardRequest && other.deviceId == deviceId && other.range == range;

  @override
  int get hashCode => Object.hash(deviceId, range);

  @override
  String toString() => 'DashboardRequest(deviceId: $deviceId, range: $range)';
}

final dashboardAggregatedProvider = FutureProvider.family<List<Map<String, dynamic>>, DashboardRequest>((ref, req) async {
  final repo = ref.read(readingsRepositoryProvider);
  final readings = await repo.history(req.deviceId, limit: 1000);

  DateTime toDate(dynamic ts) {
    if (ts == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (ts is DateTime) return ts.toUtc();
    if (ts is String) return DateTime.tryParse(ts)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  final now = DateTime.now().toUtc();
  Map<DateTime, List<Reading>> buckets = {};

  if (req.range == TimeRange.day) {
    final cutoff = now.subtract(const Duration(hours: 24));
    final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
    for (final r in filtered) {
      final ts = toDate(r.ts);
      final bucket = DateTime.utc(ts.year, ts.month, ts.day, ts.hour);
      buckets.putIfAbsent(bucket, () => []).add(r);
    }
    for (int i = 0; i < 24; i++) {
      final b = DateTime.utc(now.year, now.month, now.day, now.hour).subtract(Duration(hours: i));
      buckets.putIfAbsent(b, () => []);
    }
  } else if (req.range == TimeRange.week) {
    final cutoff = now.subtract(const Duration(days: 7));
    final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
    for (final r in filtered) {
      final ts = toDate(r.ts);
      final bucket = DateTime.utc(ts.year, ts.month, ts.day);
      buckets.putIfAbsent(bucket, () => []).add(r);
    }
    for (int i = 0; i < 7; i++) {
      final b = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: i));
      buckets.putIfAbsent(b, () => []);
    }
  } else if (req.range == TimeRange.month) {
    final cutoff = now.subtract(const Duration(days: 30));
    final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
    for (final r in filtered) {
      final ts = toDate(r.ts);
      final bucket = DateTime.utc(ts.year, ts.month, ts.day);
      buckets.putIfAbsent(bucket, () => []).add(r);
    }
    for (int i = 0; i < 30; i++) {
      final b = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: i));
      buckets.putIfAbsent(b, () => []);
    }
  } else {
    final cutoff = DateTime.utc(now.year - 1, now.month, now.day);
    final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
    for (final r in filtered) {
      final ts = toDate(r.ts);
      final bucket = DateTime.utc(ts.year, ts.month);
      buckets.putIfAbsent(bucket, () => []).add(r);
    }
    for (int i = 0; i < 12; i++) {
      final dt = DateTime.utc(now.year, now.month);
      final b = DateTime.utc(dt.year, dt.month - i);
      final adjusted = DateTime.utc(b.year, b.month);
      buckets.putIfAbsent(adjusted, () => []);
    }
  }

  final points = buckets.entries.map((e) {
    final list = e.value;
    double avgTemp = 0;
    double avgHum = 0;
    double avgLum = 0;
    if (list.isNotEmpty) {
      avgTemp = list.map((r) => r.temperatureC ?? 0.0).reduce((a, b) => a + b) / list.length;
      avgHum = list.map((r) => r.humidityPct ?? 0.0).reduce((a, b) => a + b) / list.length;
      avgLum = list.map((r) => r.luminosityPct ?? 0.0).reduce((a, b) => a + b) / list.length;
    }
    return {
      'ts': e.key,
      'temperature': double.parse(avgTemp.toStringAsFixed(2)),
      'humidity': double.parse(avgHum.toStringAsFixed(2)),
      'luminosity': double.parse(avgLum.toStringAsFixed(2)),
      'count': list.length,
    };
  }).toList();
  points.sort((a, b) => (a['ts'] as DateTime).compareTo(b['ts'] as DateTime));
  return points;
});
