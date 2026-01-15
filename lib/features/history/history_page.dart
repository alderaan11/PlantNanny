import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_providers.dart';
import 'package:plant_nanny/data/providers/device_metadata_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final String deviceId;

  const HistoryPage({required this.deviceId, super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with WidgetsBindingObserver {
  TimeRange _selectedRange = TimeRange.day;
  Timer? _refreshTimer;
  DateTime _lastRefresh = DateTime.now();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isVisible = true;
      _startTimer();
      _refreshData(); // Refresh immediately when coming back
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isVisible = false;
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    // Auto-refresh every 1 second while visible
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isVisible) _refreshData();
    });
  }

  void _refreshData() {
    if (!mounted) return;
    final seriesReq = DashboardRequest(deviceId: widget.deviceId, range: _selectedRange);
    ref.invalidate(dashboardAggregatedProvider(seriesReq));
    // Force rebuild by updating state
    setState(() {
      _lastRefresh = DateTime.now();
    });
  }

  String _formatRefreshTime() {
    final now = DateTime.now();
    final diff = now.difference(_lastRefresh);
    if (diff.inSeconds < 5) return 'à l\'instant';
    if (diff.inSeconds < 60) return 'il y a ${diff.inSeconds}s';
    return 'il y a ${diff.inMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final seriesReq = DashboardRequest(deviceId: widget.deviceId, range: _selectedRange);
    final series = ref.watch(dashboardAggregatedProvider(seriesReq));
    final meta = ref.watch(deviceMetadataProvider)[widget.deviceId];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Toutes les données'),
            Text(
              'Actualisé ${_formatRefreshTime()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: TimeRange.values.map((tr) {
                    final label = tr == TimeRange.day
                        ? '24h'
                        : tr == TimeRange.week
                            ? '7j'
                            : tr == TimeRange.month
                                ? '30j'
                                : 'Année';
                    return ChoiceChip(
                      label: Text(label),
                      selected: _selectedRange == tr,
                      onSelected: (s) => setState(() => _selectedRange = tr),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: series.when(
                data: (points) {
                  if (points.isEmpty) return const Center(child: Text('Aucune donnée pour cette période'));
                  final temps = points.map((p) => p['temperature'] as double).toList();
                  // Reverse points for list view (newest first)
                  final reversedPoints = points.reversed.toList();
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        SizedBox(height: 180, child: _SimpleLineChart(values: temps)),
                        const SizedBox(height: 8),
                        // Show last update time
                        if (reversedPoints.isNotEmpty)
                          Text(
                            'Dernière donnée: ${(reversedPoints.first['ts'] as DateTime).toLocal()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: reversedPoints.length,
                            itemBuilder: (_, i) {
                              final p = reversedPoints[i];
                              final ts = p['ts'] as DateTime;
                              return ListTile(
                                title: Text('${p['temperature']} °C • ${p['humidity']} % • ${p['luminosity']} %'),
                                subtitle: Text(ts.toLocal().toString()),
                              );
                            },
                          ),
                        ),
                      ]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
            if (meta?.comments != null && meta!.comments!.isNotEmpty)
              const SizedBox(height: 16),
            if (meta?.comments != null && meta!.comments!.isNotEmpty)
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          meta!.comments!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<double> values;
  const _SimpleLineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return CustomPaint(size: Size(w, h), painter: _LinePainter(values, min, max));
    });
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final double min;
  final double max;
  _LinePainter(this.values, this.min, this.max);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final normalized = (values[i] - min) / (max - min);
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values;
}
