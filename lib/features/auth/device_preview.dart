import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/devices_repository.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_page.dart';

class DevicePreview extends ConsumerWidget {
  final String deviceId;
  final String name;
  const DevicePreview({required this.deviceId, required this.name, super.key});

  IconData _luminosityIcon(double lum) {
    if (lum >= 70) return Icons.wb_sunny;
    if (lum >= 30) return Icons.wb_cloudy;
    if (lum >= 10) return Icons.grain; // drizzle/rain proxy
    return Icons.ac_unit; // very low light -> snow icon as proxy
  }

  Color _lumColor(double lum, BuildContext context) {
    if (lum >= 70) return Colors.amber;
    if (lum >= 30) return Colors.grey;
    if (lum >= 10) return Colors.blueGrey;
    return Colors.blueAccent;
  }

  bool _needsWater(double humidity) => humidity < 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(dashboardProvider(deviceId));

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DashboardPage(deviceId: deviceId))),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
            child: readingAsync.when(
              data: (r) {
                final lum = r.luminosityPct?.toDouble() ?? 0.0;
                final hum = r.humidityPct?.toDouble() ?? 0.0;
                final temp = r.temperatureC?.toDouble() ?? 0.0;
                final needs = _needsWater(hum);
                return ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72, maxHeight: 140),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Flexible(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                        Icon(_luminosityIcon(lum), color: _lumColor(lum, context)),
                      ]),
                      const SizedBox(height: 6),
                      // Allow the temperature to shrink if there's not enough vertical space
                      Flexible(
                        child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text('${temp.toStringAsFixed(1)} °C', style: Theme.of(context).textTheme.titleLarge)),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.opacity, size: 18, color: Color(0xFF606C38)),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${hum.toStringAsFixed(0)} %', overflow: TextOverflow.ellipsis, maxLines: 1)),
                        const SizedBox(width: 12),
                        if (needs)
                          Chip(label: const Text('Arroser'), visualDensity: VisualDensity.compact, backgroundColor: Theme.of(context).colorScheme.errorContainer, labelStyle: const TextStyle(fontSize: 12)),
                      ]),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ),
      );
  }
}
