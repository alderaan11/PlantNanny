import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'devices_controller.dart';
import 'package:plant_nanny/features/dashboard/dashboard_page.dart';
import 'package:plant_nanny/data/providers/device_metadata_provider.dart';
import 'package:plant_nanny/data/models/device_metadata.dart';
import 'package:plant_nanny/data/repositories/devices_repository.dart';
import 'package:plant_nanny/core/widgets/api_error_widget.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes capteurs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/devices/add-bluetooth'),
        child: const Icon(Icons.add, size: 32),
      ),
      body: devices.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Aucun appareil trouvé.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed('/devices/add-bluetooth'),
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Ajouter un appareil'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final device = list[i];
              final meta = ref.watch(deviceMetadataProvider)[device.deviceId];

              String subtitleText() {
                if (meta != null) {
                  final parts = <String>[];
                  if (meta.plantType != null) parts.add(meta.plantType!);
                  parts.add(meta.isOutdoor ? 'Extérieur' : 'Intérieur');
                  parts.add('${meta.baseDoseSec} sec');
                  return parts.join(' • ');
                }
                final ls = device.lastSeen != null
                    ? 'Dernière vue: ${device.lastSeen}'
                    : null;
                return ls ?? device.deviceId;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .12),
                    child: meta?.plantType != null
                        ? Text(
                            meta!.plantType![0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.sensor_window, color: Colors.green),
                  ),
                  title: Text(
                    device.name ?? device.deviceId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(subtitleText()),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await _showEditMetadataSheet(
                          context,
                          ref,
                          device.deviceId,
                          meta,
                        );
                      } else if (v == 'remove') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Supprimer l\'appareil'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cet appareil ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          try {
                            await ref
                                .read(devicesRepositoryProvider)
                                .unregister(device.deviceId);
                            ref
                                .read(deviceMetadataProvider.notifier)
                                .remove(device.deviceId);
                            // Refresh the devices list to update the UI
                            ref.invalidate(devicesControllerProvider);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appareil supprimé'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'edit', child: Text('Éditer')),
                      PopupMenuItem(value: 'remove', child: Text('Supprimer')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DashboardPage(deviceId: device.deviceId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ApiErrorWidget(
          error: e,
          onRetry: () => ref.invalidate(devicesControllerProvider),
        ),
      ),
    );
  }

  Future<void> _showEditMetadataSheet(
    BuildContext context,
    WidgetRef ref,
    String deviceId,
    DeviceMetadata? existing,
  ) async {
    final meta = existing?.copyWith() ?? DeviceMetadata(baseDoseSec: 5);
    final plantController = TextEditingController(text: meta.plantType ?? '');
    final doseController = TextEditingController(
      text: meta.baseDoseSec.toString(),
    );
    final commentsController = TextEditingController(text: meta.comments ?? '');
    bool isOutdoor = meta.isOutdoor;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Éditer le capteur',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: plantController,
                decoration: const InputDecoration(
                  labelText: 'Type de plante (ex: Tomate)',
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx, setState) => SwitchListTile(
                  value: isOutdoor,
                  title: const Text('Extérieur'),
                  onChanged: (v) => setState(() => isOutdoor = v),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: doseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dose de base (sec)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: commentsController,
                decoration: const InputDecoration(labelText: 'Commentaires'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final newMeta = DeviceMetadata(
                    plantType: plantController.text.trim().isEmpty
                        ? null
                        : plantController.text.trim(),
                    isOutdoor: isOutdoor,
                    baseDoseSec:
                        int.tryParse(doseController.text.trim()) ??
                        meta.baseDoseSec,
                    comments: commentsController.text.trim().isEmpty
                        ? null
                        : commentsController.text.trim(),
                  );
                  ref
                      .read(deviceMetadataProvider.notifier)
                      .setMetadata(deviceId, newMeta);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Métadonnées enregistrées')),
                  );
                },
                child: const Text('Enregistrer'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    plantController.dispose();
    doseController.dispose();
    commentsController.dispose();
  }
}
