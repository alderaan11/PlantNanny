import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_controller.dart';
import 'package:plant_nanny/data/repositories/commands_repository.dart';
import 'dashboard_providers.dart';
import 'package:plant_nanny/data/providers/device_metadata_provider.dart';
import 'package:plant_nanny/data/models/device_metadata.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  TimeRange _selectedRange = TimeRange.day;

  Future<void> _showPumpDialog() async {
    final meta = ref.watch(deviceMetadataProvider)[widget.deviceId];
    final initial = meta?.baseDoseMs.toString() ?? '5000';
    final controller = TextEditingController(text: initial);
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arroser - durée (ms)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Durée en ms'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(int.tryParse(controller.text)), child: const Text('Confirmer')),
        ],
      ),
    );

    if (result != null && result > 0) {
      try {
        await ref.read(commandsRepositoryProvider).pump(widget.deviceId, result);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arrosage envoyé')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur en envoyant la commande: ${e.toString()}')));
      }
    }
  }

  Future<void> _showEditMetadataSheet() async {
    final existing = ref.read(deviceMetadataProvider)[widget.deviceId];
    final meta = existing?.copyWith() ?? DeviceMetadata(baseDoseMs: 5000);
    final plantController = TextEditingController(text: meta.plantType ?? '');
    final doseController = TextEditingController(text: meta.baseDoseMs.toString());
    final commentsController = TextEditingController(text: meta.comments ?? '');
    bool isOutdoor = meta.isOutdoor;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Modifier le capteur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(controller: plantController, decoration: const InputDecoration(labelText: 'Type de plante')),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (ctx, setState) => SwitchListTile(
                value: isOutdoor,
                title: const Text('Extérieur'),
                onChanged: (v) => setState(() => isOutdoor = v),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(controller: doseController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dose de base (ms)')),
            const SizedBox(height: 8),
            TextFormField(controller: commentsController, decoration: const InputDecoration(labelText: 'Commentaires'), minLines: 2, maxLines: 4),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final newMeta = DeviceMetadata(
                  plantType: plantController.text.trim().isEmpty ? null : plantController.text.trim(),
                  isOutdoor: isOutdoor,
                  baseDoseMs: int.tryParse(doseController.text.trim()) ?? meta.baseDoseMs,
                  comments: commentsController.text.trim().isEmpty ? null : commentsController.text.trim(),
                );
                ref.read(deviceMetadataProvider.notifier).setMetadata(widget.deviceId, newMeta);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capteur modifié')));
              },
              child: const Text('Enregistrer'),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );

    plantController.dispose();
    doseController.dispose();
    commentsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = ref.watch(dashboardProvider(widget.deviceId));
    final seriesReq = DashboardRequest(deviceId: widget.deviceId, range: _selectedRange);
    final series = ref.watch(dashboardAggregatedProvider(seriesReq));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceId),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (v) async {
              if (v == 'edit') {
                await _showEditMetadataSheet();
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'edit', child: Text('Modifier le capteur')),
            ],
          ),
        ],
      ),
      body: reading.when(
        data: (r) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    // Left: compact device stats (allow truncation)
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r.temperatureC.toStringAsFixed(1)} °C', style: Theme.of(context).textTheme.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Hum: ${r.humidityPct.toStringAsFixed(1)} % • Lum: ${r.luminosityPct.toStringAsFixed(1)} %', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    // Right: actions - use Wrap so buttons can wrap instead of causing overflow
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(spacing: 8, alignment: WrapAlignment.end, children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await ref.read(commandsRepositoryProvider).forceReading(widget.deviceId);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande de captage envoyée')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
                              }
                            },
                            child: const Text('Forcer captage'),
                          ),
                          ElevatedButton(onPressed: _showPumpDialog, child: const Text('Arroser')),
                        ]),
                      ),
                    )
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Range selector
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

              // Chart area
              Expanded(
                child: series.when(
                  data: (points) {
                    if (points.isEmpty) return const Center(child: Text('Aucune donnée pour cette période'));
                    final temps = points.map((p) => p['temperature'] as double).toList();
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(children: [
                          SizedBox(height: 180, child: _SimpleLineChart(values: temps)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: points.length,
                              itemBuilder: (_, i) {
                                final p = points[i];
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

            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<double> values;
  const _SimpleLineChart({required this.values, super.key});

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
  final double min, max;
  _LinePainter(this.values, this.min, this.max);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    final n = values.length;
    for (int i = 0; i < n; i++) {
      final x = (i / (n - 1)) * size.width;
      final y = size.height - ((values[i] - min) / (max - min + 0.0001)) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AllDataPage extends ConsumerWidget {
  const AllDataPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simple list of historical readings
    final historyFuture = ref.watch(dashboardAggregatedProvider(DashboardRequest(deviceId: deviceId, range: TimeRange.month)));
    return Scaffold(
      appBar: AppBar(title: const Text('Toutes les données')),
      body: historyFuture.when(
        data: (points) => ListView.builder(
          itemCount: points.length,
          itemBuilder: (_, i) {
            final p = points[i];
            final ts = p['ts'] as DateTime;
            return ListTile(
              title: Text('${p['temperature']} °C'),
              subtitle: Text(ts.toLocal().toString()),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
