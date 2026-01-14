import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny/data/repositories/devices_repository.dart';
import 'package:plant_nanny/data/repositories/commands_repository.dart';
import 'package:plant_nanny/data/providers/per_device_pump_provider.dart';
import 'package:plant_nanny/data/providers/device_metadata_provider.dart';
import 'package:plant_nanny/features/devices/devices_controller.dart';
import 'package:plant_nanny/data/models/device_metadata.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

class ArrosagePage extends ConsumerWidget {
  const ArrosagePage({super.key});

  Future<void> _pumpDevice(BuildContext context, WidgetRef ref, String deviceId, int duration) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arroser le capteur'),
        content: Text('Arroser $deviceId pendant $duration sec ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Arroser')),
        ],
      ),
    );
    if (ok != true) return;
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      await ref.read(commandsRepositoryProvider).pump(deviceId, duration);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arrosage envoyé à $deviceId')));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _pumpAll(BuildContext context, WidgetRef ref, List devices) async {
    final per = ref.read(perDevicePumpDurationProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arroser tous les capteurs'),
        content: const Text('Arroser tous les capteurs ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Arroser')),
        ],
      ),
    );
    if (ok != true) return;

    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final results = await Future.wait(devices.map((d) async {
        final deviceId = d.deviceId;
        final duration = per[deviceId] ?? ref.read(deviceMetadataProvider)[deviceId]?.baseDoseSec ?? 5;
        try {
          await ref.read(commandsRepositoryProvider).pump(deviceId, duration);
          return null;
        } catch (e) {
          return 'Erreur pour $deviceId: ${e.toString()}';
        }
      }));

      Navigator.of(context).pop();
      final errors = results.whereType<String>().toList();
      if (errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arrosage envoyé à ${devices.length} appareils')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arrosage partiel: ${errors.length} erreurs. Voir la console.')));
        for (final e in errors) print(e);
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arrosage')),
      body: devicesAsync.when(
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Aucun capteur enregistré'));
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final d = list[i];
                    final curMap = ref.watch(perDevicePumpDurationProvider);
                    final curVal = curMap[d.deviceId] ?? ref.read(deviceMetadataProvider)[d.deviceId]?.baseDoseSec ?? 5;
                    return _SliderListTile(
                      device: d,
                      currentValue: curVal,
                      onChanged: (v) {
                        ref.read(perDevicePumpDurationProvider.notifier).setDurationFor(d.deviceId, v);
                      },
                      onChangeEnd: (v) {
                        final meta = ref.read(deviceMetadataProvider)[d.deviceId];
                        ref.read(deviceMetadataProvider.notifier).setMetadata(
                          d.deviceId, 
                          (meta?.copyWith(baseDoseSec: v)) ?? (DeviceMetadata(baseDoseSec: v))
                        );
                      },
                      onPump: () => _pumpDevice(context, ref, d.deviceId, curVal),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () => _pumpAll(context, ref, list),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF606C38),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Arroser tous'),
                ),
              ])
            ]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _SliderListTile extends StatefulWidget {
  final Device device;
  final int currentValue;
  final Function(int) onChanged;
  final Function(int) onChangeEnd;
  final VoidCallback onPump;

  const _SliderListTile({
    required this.device,
    required this.currentValue,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onPump,
  });

  @override
  State<_SliderListTile> createState() => _SliderListTileState();
}

class _SliderListTileState extends State<_SliderListTile> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentValue.toDouble().clamp(1, 3600);
  }

  @override
  void didUpdateWidget(_SliderListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _sliderValue = widget.currentValue.toDouble().clamp(1, 3600);
    }
  }

  String _formatDuration(int seconds) {
    if (seconds >= 60) {
      final minutes = (seconds / 60).round();
      return '$minutes min';
    }
    return '$seconds sec';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.name ?? widget.device.deviceId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            min: 1,
            max: 3600,
            divisions: 359,
            value: _sliderValue,
            onChanged: (v) {
              setState(() {
                _sliderValue = v;
              });
              widget.onChanged(v.round());
            },
            onChangeEnd: (v) {
              widget.onChangeEnd(v.round());
            },
          ),
          Text(_formatDuration(widget.currentValue), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: widget.onPump,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF606C38),
          foregroundColor: Colors.white,
        ),
        child: const Text('Arroser'),
      ),
    );
  }
}
