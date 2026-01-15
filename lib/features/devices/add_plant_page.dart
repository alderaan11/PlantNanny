import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/devices_repository.dart';
import '../../data/providers/device_metadata_provider.dart';
import '../../data/models/device_metadata.dart';
import 'package:plant_nanny/features/dashboard/dashboard_page.dart';
import 'devices_controller.dart';

class AddPlantPage extends ConsumerStatefulWidget {
  final String? deviceId;

  const AddPlantPage({super.key, this.deviceId});

  @override
  ConsumerState<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends ConsumerState<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _pairingController = TextEditingController();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController(text: '5000');
  final _commentsController = TextEditingController();
  String? _plantType;
  bool _isOutdoor = false;

  bool get _isBluetoothFlow => widget.deviceId != null;

  final List<String> _plantTypes = [
    'Tomate',
    'Basilic',
    'Fougère',
    'Succulente',
    'Pothos',
    'Menthe',
    'Lavande',
    'Autre',
  ];

  @override
  void dispose() {
    _pairingController.dispose();
    _nameController.dispose();
    _doseController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final pairing = _isBluetoothFlow
        ? (widget.deviceId ?? '')
        : _pairingController.text.trim();
    final name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    final baseSec = int.tryParse(_doseController.text.trim()) ?? 5;

    try {
      final device = await ref
          .read(devicesRepositoryProvider)
          .register(pairing, name: name);

      final meta = DeviceMetadata(
        plantType: _plantType,
        isOutdoor: _isOutdoor,
        baseDoseSec: baseSec,
        comments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      );
      ref
          .read(deviceMetadataProvider.notifier)
          .setMetadata(device.deviceId, meta);

      // Refresh the devices list to show the new device
      ref.invalidate(devicesControllerProvider);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appareil enregistré')));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardPage(deviceId: device.deviceId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une plante')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 48,
                            color: cs.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isBluetoothFlow
                                ? 'Nommer votre plante'
                                : 'Pairer un capteur',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isBluetoothFlow
                                ? 'Configurez les informations de votre plante'
                                : 'Entrez le code de pairing du capteur ou simulez-en un',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                      if (!_isBluetoothFlow) ...[
                        TextFormField(
                          controller: _pairingController,
                          decoration: const InputDecoration(
                            labelText: 'Code de pairing',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Code requis' : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText:
                              'Nom de l\'appareil (ex: Tomates du balcon)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return _plantTypes;
                          }
                          return _plantTypes.where(
                            (p) => p.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          );
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              controller.text = _plantType ?? '';
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Type de plante',
                                ),
                                onChanged: (v) => _plantType = v,
                              );
                            },
                        onSelected: (s) => _plantType = s,
                      ),

                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: _isOutdoor,
                        title: const Text('Extérieur'),
                        onChanged: (v) => setState(() => _isOutdoor = v),
                      ),

                      TextFormField(
                        controller: _doseController,
                        decoration: const InputDecoration(
                          labelText: 'Dose de base (sec)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null)
                            ? 'Entrer un nombre'
                            : null,
                      ),

                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(
                          labelText: 'Commentaires (optionnel)',
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
