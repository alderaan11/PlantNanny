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
      other is DashboardRequest &&
          other.deviceId == deviceId &&
          other.range == range;

  @override
  int get hashCode => Object.hash(deviceId, range);

  @override
  String toString() => 'DashboardRequest(deviceId: $deviceId, range: $range)';
}

final dashboardAggregatedProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, DashboardRequest>((ref, req) async {
      // autoDispose ensures we stop fetching when page is not visible
      final repo = ref.watch(readingsRepositoryProvider);
      final readings = await repo.history(req.deviceId, limit: 1000);

      DateTime toDate(dynamic ts) {
        if (ts == null) return DateTime.fromMillisecondsSinceEpoch(0);
        if (ts is DateTime) return ts.toUtc();
        if (ts is String) {
          return DateTime.tryParse(ts)?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0);
        }
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      final now = DateTime.now().toUtc();
      Map<DateTime, List<Reading>> buckets = {};

      if (req.range == TimeRange.day) {
        final cutoff = now.subtract(const Duration(hours: 24));
        final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
        for (final r in filtered) {
          final ts = toDate(r.ts);
          // Use 15-minute buckets for finer granularity
          final minute = (ts.minute ~/ 15) * 15;
          final bucket = DateTime.utc(
            ts.year,
            ts.month,
            ts.day,
            ts.hour,
            minute,
          );
          buckets.putIfAbsent(bucket, () => []).add(r);
        }
        // Empty buckets are filtered out later, no need to pre-create them
      } else if (req.range == TimeRange.week) {
        final cutoff = now.subtract(const Duration(days: 7));
        final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
        for (final r in filtered) {
          final ts = toDate(r.ts);
          final bucket = DateTime.utc(ts.year, ts.month, ts.day);
          buckets.putIfAbsent(bucket, () => []).add(r);
        }
      } else if (req.range == TimeRange.month) {
        final cutoff = now.subtract(const Duration(days: 30));
        final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
        for (final r in filtered) {
          final ts = toDate(r.ts);
          final bucket = DateTime.utc(ts.year, ts.month, ts.day);
          buckets.putIfAbsent(bucket, () => []).add(r);
        }
      } else {
        final cutoff = DateTime.utc(now.year - 1, now.month, now.day);
        final filtered = readings.where((r) => toDate(r.ts).isAfter(cutoff));
        for (final r in filtered) {
          final ts = toDate(r.ts);
          final bucket = DateTime.utc(ts.year, ts.month);
          buckets.putIfAbsent(bucket, () => []).add(r);
        }
      }

      final points = buckets.entries
          .where(
            (e) => e.value.isNotEmpty,
          ) // Filter out empty buckets (no real data)
          .map((e) {
            final list = e.value;
            final avgTemp =
                list
                    .map((r) => r.temperatureC.toDouble())
                    .reduce((a, b) => a + b) /
                list.length;
            final avgHum =
                list
                    .map((r) => r.humidityPct.toDouble())
                    .reduce((a, b) => a + b) /
                list.length;
            final avgLum =
                list
                    .map((r) => r.luminosityPct.toDouble())
                    .reduce((a, b) => a + b) /
                list.length;
            return {
              'ts': e.key,
              'temperature': double.parse(avgTemp.toStringAsFixed(2)),
              'humidity': double.parse(avgHum.toStringAsFixed(2)),
              'luminosity': double.parse(avgLum.toStringAsFixed(2)),
              'count': list.length,
            };
          })
          .toList();
      points.sort(
        (a, b) => (a['ts'] as DateTime).compareTo(b['ts'] as DateTime),
      );
      return points;
    });
