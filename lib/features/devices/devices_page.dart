import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'devices_controller.dart';
import 'package:plant_nanny/features/dashboard/dashboard_page.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes plantes')),
      body: devices.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Aucun appareil trouvé.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Open a dashboard with a fake device id for testing
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(deviceId: 'fake-device-1'),
                        ),
                      );
                    },
                    child: const Text('Ajouter un device de test'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(list[i].name ?? list[i].deviceId),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardPage(deviceId: list[i].deviceId),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
