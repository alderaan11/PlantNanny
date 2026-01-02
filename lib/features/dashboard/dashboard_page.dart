import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_controller.dart';
import 'package:plant_nanny/data/repositories/commands_repository.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(dashboardProvider(deviceId));

    return Scaffold(
      appBar: AppBar(title: Text(deviceId)),
      body: reading.when(
        data: (r) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('${r.temperatureC.toStringAsFixed(1)} °C'),
              Text('${r.humidityPct.toStringAsFixed(1)} %'),
              Text('${r.luminosityPct.toStringAsFixed(1)} %'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(commandsRepositoryProvider).forceReading(deviceId),
                child: const Text('Forcer captage'),
              ),
              ElevatedButton(
                onPressed: () =>
                    ref.read(commandsRepositoryProvider).pump(deviceId, 5000),
                child: const Text('Arroser 5s'),
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
