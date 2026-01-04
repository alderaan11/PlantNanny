import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth/auth_notifier.dart';
import '../../features/auth/device_preview.dart';
import '../../features/devices/devices_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    String displayName = 'Utilisateur';
    final token = auth.token ?? '';
    if (token.startsWith('dev-token-')) {
      var uid = token.replaceFirst('dev-token-', '');
      if (uid.contains('@')) uid = uid.split('@')[0];
      displayName = uid;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PlantNanny')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue, $displayName!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Aperçu capteurs (jusqu'à 3)
            Consumer(builder: (context, ref, _) {
              final devices = ref.watch(devicesControllerProvider);
              return devices.when(
                data: (list) {
                  if (list.isEmpty) return const SizedBox.shrink();
                  final shown = list.length > 3 ? list.sublist(0, 3) : list;
                  return SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DevicePreview(
                          deviceId: shown[i].deviceId,
                          name: shown[i].name ?? shown[i].deviceId,
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: shown.length,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

