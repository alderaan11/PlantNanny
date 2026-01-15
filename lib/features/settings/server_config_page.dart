import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../core/server_config_provider.dart';
import '../devices/devices_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_providers.dart';
import 'mqtt_config_page.dart';

/// Connection status enum
enum ConnectionStatus { unknown, checking, connected, failed }

class ServerConfigPage extends ConsumerStatefulWidget {
  const ServerConfigPage({super.key});

  @override
  ConsumerState<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends ConsumerState<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isEditing = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.unknown;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.text = ref.read(serverConfigProvider);
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final serverUrl = ref.read(serverConfigProvider);
    setState(() {
      _connectionStatus = ConnectionStatus.checking;
      _connectionError = null;
    });

    try {
      final uri = Uri.parse('$serverUrl/health');
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      if (mounted) {
        setState(() {
          if (response.statusCode == 200) {
            _connectionStatus = ConnectionStatus.connected;
            _connectionError = null;
            // Invalidate providers to refresh data from the new/working server
            _invalidateServerDependentProviders();
          } else {
            _connectionStatus = ConnectionStatus.failed;
            _connectionError = 'Server returned status ${response.statusCode}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = ConnectionStatus.failed;
          _connectionError = e.toString();
        });
      }
    }
  }

  /// Invalidate all providers that depend on the server connection
  /// This forces them to refetch data when the connection is restored
  void _invalidateServerDependentProviders() {
    // Invalidate devices controller to refresh the device list
    ref.invalidate(devicesControllerProvider);
    // Invalidate all dashboard providers (they're family providers, so invalidate the whole family)
    ref.invalidate(dashboardProvider);
    // Invalidate aggregated dashboard data provider
    ref.invalidate(dashboardAggregatedProvider);
  }

  Future<void> _saveUrl() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(serverConfigProvider.notifier)
          .setServerUrl(_urlController.text.trim());
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse du serveur enregistrée'),
            backgroundColor: Color(0xFF606C38),
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    await ref.read(serverConfigProvider.notifier).resetToDefault();
    _urlController.text = ref.read(serverConfigProvider);
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse du serveur réinitialisée'),
          backgroundColor: Color(0xFF606C38),
        ),
      );
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une URL';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL invalide (ex: http://192.168.1.100:8080)';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Utilisez http:// ou https://';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = ref.watch(serverConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        actions: [
          IconButton(
            icon: _connectionStatus == ConnectionStatus.checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _connectionStatus == ConnectionStatus.checking
                ? null
                : _checkConnection,
            tooltip: 'Tester la connexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatusCard(),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.dns, color: Color(0xFF606C38)),
                            const SizedBox(width: 8),
                            Text(
                              'Serveur PlantNanny',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Adresse actuelle:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        if (!_isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentUrl,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _urlController.text = currentUrl;
                                  setState(() => _isEditing = true);
                                },
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              TextFormField(
                                controller: _urlController,
                                validator: _validateUrl,
                                decoration: const InputDecoration(
                                  hintText: 'http://192.168.1.100:8080',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.link),
                                ),
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() => _isEditing = false);
                                    },
                                    child: const Text('Annuler'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _saveUrl,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF606C38),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Enregistrer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.restore),
                    label: const Text('Réinitialiser par défaut'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.router, color: Color(0xFF606C38)),
                    title: const Text('Configuration MQTT'),
                    subtitle: const Text('Paramètres du broker MQTT'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MqttConfigPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Aide',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'L\'adresse du serveur doit correspondre à l\'endroit où le serveur PlantNanny est en cours d\'exécution.\n\n'
                          '• Pour un serveur local sur PC: http://IP_DU_PC:8080\n'
                          '• L\'émulateur Android utilise 10.0.2.2 pour accéder à localhost du PC',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blue.shade900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_connectionStatus) {
      case ConnectionStatus.unknown:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'État de connexion inconnu';
        break;
      case ConnectionStatus.checking:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Vérification en cours...';
        break;
      case ConnectionStatus.connected:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Serveur connecté';
        break;
      case ConnectionStatus.failed:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Connexion échouée';
        break;
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _connectionStatus == ConnectionStatus.checking
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: statusColor,
                        ),
                      )
                    : Icon(statusIcon, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _connectionStatus == ConnectionStatus.checking
                      ? null
                      : _checkConnection,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tester'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            if (_connectionError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de l\'erreur:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _connectionError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
