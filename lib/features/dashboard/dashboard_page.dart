import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_controller.dart';
import 'package:plant_nanny/data/repositories/commands_repository.dart';
import 'dashboard_providers.dart';
import 'package:plant_nanny/data/providers/device_metadata_provider.dart';
import 'package:plant_nanny/data/models/device_metadata.dart';
import 'package:plant_nanny/core/widgets/api_error_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key, required this.deviceId});
  final String deviceId;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<void> _showPumpDialog() async {
    final meta = ref.watch(deviceMetadataProvider)[widget.deviceId];
    final initial = meta?.baseDoseSec.toString() ?? '5';
    final controller = TextEditingController(text: initial);
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arroser - durée (sec)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Durée en secondes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(ctx).pop(int.tryParse(controller.text)),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      try {
        await ref
            .read(commandsRepositoryProvider)
            .pump(widget.deviceId, result);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Arrosage envoyé')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur en envoyant la commande: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _showEditMetadataSheet() async {
    final existing = ref.read(deviceMetadataProvider)[widget.deviceId];
    final meta = existing?.copyWith() ?? DeviceMetadata(baseDoseSec: 5);
    final nameController = TextEditingController(text: meta.name ?? '');
    final doseController = TextEditingController(
      text: meta.baseDoseSec.toString(),
    );
    final commentsController = TextEditingController(text: meta.comments ?? '');
    bool isOutdoor = meta.isOutdoor;
    String? selectedPlantType = meta.plantType;

    // Liste des types de plantes
    final List<String> plantTypes = [
      'Tomate',
      'Basilic',
      'Fougère',
      'Succulente',
      'Pothos',
      'Menthe',
      'Lavande',
      'Cactus',
      'Rose',
      'Orchidée',
      'Persil',
      'Romarin',
      'Thym',
      'Citronnier',
      'Aloe Vera',
      'Monstera',
      'Ficus',
      'Autre',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Modifier le capteur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Champ pour le nom du capteur
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du capteur',
                    hintText: 'Ex: Tomates du balcon',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),

                // Autocomplete pour le type de plante
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: meta.plantType ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return plantTypes;
                    }
                    return plantTypes.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (String selection) {
                    selectedPlantType = selection;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Type de plante',
                            hintText: 'Tapez ou sélectionnez',
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            helperText: 'Vous pouvez taper un nom personnalisé',
                          ),
                          onChanged: (value) {
                            selectedPlantType = value;
                          },
                        );
                      },
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
                      name: nameController.text.trim().isEmpty
                          ? null
                          : nameController.text.trim(),
                      plantType: selectedPlantType?.trim().isEmpty ?? true
                          ? null
                          : selectedPlantType?.trim(),
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
                        .setMetadata(widget.deviceId, newMeta);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Capteur modifié')),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading = ref.watch(dashboardProvider(widget.deviceId));
    final meta = ref.watch(deviceMetadataProvider)[widget.deviceId];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meta?.name ?? widget.deviceId,
              style: const TextStyle(fontSize: 18),
            ),
            if (meta?.plantType != null)
              Text(
                meta!.plantType!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.invalidate(dashboardProvider(widget.deviceId));
              ref.invalidate(dashboardAggregatedProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données actualisées')),
              );
            },
          ),
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
                elevation: 6,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Scores affichés de manière plus visible
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ScoreWidget(
                            icon: Icons.thermostat,
                            label: 'Température',
                            value: '${r.temperatureC.toStringAsFixed(1)}°C',
                            color: Colors.orange,
                          ),
                          _ScoreWidget(
                            icon: Icons.water_drop,
                            label: 'Humidité',
                            value: '${r.humidityPct.toStringAsFixed(0)}%',
                            color: Colors.blue,
                          ),
                          _ScoreWidget(
                            icon: Icons.wb_sunny,
                            label: 'Luminosité',
                            value: '${r.luminosityPct.toStringAsFixed(0)}%',
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Boutons d'action
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(commandsRepositoryProvider)
                                      .forceReading(widget.deviceId);

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Demande de captage envoyée - Rafraîchissement dans 3s',
                                      ),
                                    ),
                                  );

                                  // Rafraîchir les données après quelques secondes
                                  Future.delayed(const Duration(seconds: 3), () {
                                    // Invalider les providers pour forcer le rechargement
                                    ref.invalidate(
                                      dashboardProvider(widget.deviceId),
                                    );
                                    ref.invalidate(dashboardAggregatedProvider);
                                  });
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${e.toString()}'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Captage'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showPumpDialog,
                              icon: const Icon(Icons.water_drop),
                              label: const Text('Arroser'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Affichage des commentaires
              if (meta?.comments != null && meta!.comments!.isNotEmpty)
                Card(
                  color: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.comment,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            meta.comments!,
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
              if (meta?.comments != null && meta!.comments!.isNotEmpty)
                const SizedBox(height: 16),

              // Bouton pour accéder à toutes les données
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/history',
                      arguments: widget.deviceId,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.timeline),
                        SizedBox(width: 8),
                        Text(
                          'Voir toutes les données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorWidget(context, e),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    // Check if this is a connection error
    if (ApiErrorWidget.isConnectionError(error)) {
      return ApiErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(dashboardProvider(widget.deviceId)),
      );
    }

    // For other errors (like no data), show the no data widget
    return _buildNoDataWidget(context);
  }

  Widget _buildNoDataWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Pas encore de données',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'En attente des premières mesures du capteur...',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(dashboardProvider(widget.deviceId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher un score de manière visible
class _ScoreWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ScoreWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
