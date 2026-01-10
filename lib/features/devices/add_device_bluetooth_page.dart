import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_setup_provider.dart';
import '../../core/bluetooth_service.dart';

/// Page principale pour l'ajout d'un nouvel appareil via Bluetooth
class AddDeviceBluetoothPage extends ConsumerStatefulWidget {
  const AddDeviceBluetoothPage({super.key});

  @override
  ConsumerState<AddDeviceBluetoothPage> createState() => _AddDeviceBluetoothPageState();
}

class _AddDeviceBluetoothPageState extends ConsumerState<AddDeviceBluetoothPage> {
  @override
  void initState() {
    super.initState();
    // Réinitialiser et démarrer le scan quand on arrive sur la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceSetupProvider.notifier).reset();
      ref.read(deviceSetupProvider.notifier).rescan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(deviceSetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un appareil'),
      ),
      body: _buildBody(context, ref, setupState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DeviceSetupModel state) {
    switch (state.state) {
      case DeviceSetupState.scanning:
        return const _ScanningView();
      case DeviceSetupState.selectDevice:
        return _DeviceSelectionView(devices: state.devices);
      case DeviceSetupState.connecting:
        return const _ConnectingView();
      case DeviceSetupState.selectWifi:
        return const _WifiSelectionView();
      case DeviceSetupState.enterWifiPass:
        return _WifiPasswordView(ssid: state.ssid ?? '');
      case DeviceSetupState.sending:
        return const _SendingView();
      case DeviceSetupState.waitingWifi:
        return const _WaitingWifiView();
      case DeviceSetupState.success:
        return const _SuccessView();
      case DeviceSetupState.error:
        return _ErrorView(message: state.errorMessage ?? 'Erreur inconnue');
      case DeviceSetupState.wifiError:
        return _WifiErrorView(message: state.errorMessage ?? 'Erreur de connexion WiFi');
    }
  }
}

/// Vue de scan en cours
class _ScanningView extends StatelessWidget {
  const _ScanningView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Recherche d\'appareils...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Assurez-vous que votre appareil ESP32 est allumé',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Vue de sélection de l'appareil
class _DeviceSelectionView extends ConsumerWidget {
  final List<BluetoothEndpoint> devices;

  const _DeviceSelectionView({required this.devices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appareils trouvés',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez l\'appareil à configurer',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bluetooth, color: Colors.blue),
                  title: Text(device.name ?? 'Appareil inconnu'),
                  subtitle: Text(device.id),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ref.read(deviceSetupProvider.notifier).selectDevice(device);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(deviceSetupProvider.notifier).rescan();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Rechercher à nouveau'),
          ),
        ),
      ],
    );
  }
}

/// Vue de connexion et appairage BLE en cours
class _ConnectingView extends StatelessWidget {
  const _ConnectingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connexion en cours...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez le code PIN affiché sur l\'appareil\nlorsque le système vous le demande',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Icon(Icons.bluetooth_connected, size: 48, color: Colors.blue),
        ],
      ),
    );
  }
}

/// Vue de sélection du réseau WiFi
class _WifiSelectionView extends ConsumerWidget {
  const _WifiSelectionView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(deviceSetupProvider);
    final networks = setupState.wifiNetworks;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner le réseau WiFi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Réseaux détectés par l\'appareil',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (networks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Recherche des réseaux WiFi...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      // Allow manual SSID entry
                      _showManualSsidDialog(context, ref);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Entrer manuellement'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: networks.length + 1, // +1 for manual entry option
              itemBuilder: (context, index) {
                if (index == networks.length) {
                  // Manual entry option at the end
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.edit, color: Colors.grey),
                      title: const Text('Entrer manuellement'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showManualSsidDialog(context, ref),
                    ),
                  );
                }
                
                final network = networks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.wifi, color: Colors.green),
                    title: Text(network),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ref.read(deviceSetupProvider.notifier).selectWifi(network);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showManualSsidDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nom du réseau WiFi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'SSID',
            hintText: 'Entrez le nom du réseau',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ref.read(deviceSetupProvider.notifier).selectWifi(controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Vue de saisie du mot de passe WiFi
class _WifiPasswordView extends ConsumerStatefulWidget {
  final String ssid;

  const _WifiPasswordView({required this.ssid});

  @override
  ConsumerState<_WifiPasswordView> createState() => _WifiPasswordViewState();
}

class _WifiPasswordViewState extends ConsumerState<_WifiPasswordView> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_lock, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Mot de passe WiFi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Réseau: ${widget.ssid}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le mot de passe';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(deviceSetupProvider.notifier).backToWifiSelection();
                    },
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(deviceSetupProvider.notifier).submitWifiCredentials(_passwordController.text);
                      }
                    },
                    child: const Text('Configurer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Vue d'envoi en cours
class _SendingView extends StatelessWidget {
  const _SendingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Configuration en cours...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// Vue de succès - navigue automatiquement vers la configuration de la plante
class _SuccessView extends ConsumerStatefulWidget {
  const _SuccessView();

  @override
  ConsumerState<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends ConsumerState<_SuccessView> {
  @override
  void initState() {
    super.initState();
    // Navigue automatiquement après un court délai
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final deviceId = ref.read(deviceSetupProvider).selectedDevice?.id;
        Navigator.of(context).pushReplacementNamed(
          '/devices/configure',
          arguments: deviceId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Configuration réussie !',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Redirection vers la configuration...',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Vue d'erreur
class _ErrorView extends ConsumerWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(deviceSetupProvider.notifier).reset();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Vue d'attente de connexion WiFi
class _WaitingWifiView extends StatelessWidget {
  const _WaitingWifiView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connexion WiFi en cours...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'L\'appareil essaie de se connecter au réseau WiFi',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Icon(Icons.wifi, size: 48, color: Colors.blue),
        ],
      ),
    );
  }
}

/// Vue d'erreur WiFi avec possibilité de réessayer
class _WifiErrorView extends ConsumerWidget {
  final String message;

  const _WifiErrorView({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Erreur de connexion WiFi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(deviceSetupProvider.notifier).retryWifiConfig();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
