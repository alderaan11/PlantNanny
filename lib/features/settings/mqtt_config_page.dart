import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:io';
import '../../core/mqtt_config_provider.dart';
import '../../core/server_config_provider.dart';

/// Connection status enum for MQTT broker
enum MqttConnectionStatus { unknown, checking, connected, failed }

class MqttConfigPage extends ConsumerStatefulWidget {
  const MqttConfigPage({super.key});

  @override
  ConsumerState<MqttConfigPage> createState() => _MqttConfigPageState();
}

class _MqttConfigPageState extends ConsumerState<MqttConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;
  bool _showPassword = false;
  MqttConnectionStatus _connectionStatus = MqttConnectionStatus.unknown;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(mqttConfigProvider);
      _hostController.text = config.host;
      _portController.text = config.port.toString();
      _usernameController.text = config.username;
      _passwordController.text = config.password;
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final config = ref.read(mqttConfigProvider);
    setState(() {
      _connectionStatus = MqttConnectionStatus.checking;
      _connectionError = null;
    });

    try {
      final socket = await Socket.connect(
        config.host,
        config.port,
        timeout: const Duration(seconds: 5),
      );
      await socket.close();

      if (mounted) {
        setState(() {
          _connectionStatus = MqttConnectionStatus.connected;
          _connectionError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = MqttConnectionStatus.failed;
          _connectionError = e.toString();
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState?.validate() ?? false) {
      final config = MqttConfig(
        host: _hostController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 1883,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        enabled: ref.read(mqttConfigProvider).enabled,
      );

      await ref.read(mqttConfigProvider.notifier).setConfig(config);
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration MQTT enregistrée'),
            backgroundColor: Color(0xFF606C38),
          ),
        );
        _checkConnection();
      }
    }
  }

  Future<void> _resetToDefault() async {
    await ref.read(mqttConfigProvider.notifier).resetToDefault();
    final config = ref.read(mqttConfigProvider);
    _hostController.text = config.host;
    _portController.text = config.port.toString();
    _usernameController.text = config.username;
    _passwordController.text = config.password;
    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration MQTT réinitialisée'),
          backgroundColor: Color(0xFF606C38),
        ),
      );
    }
  }

  Future<void> _deriveFromServer() async {
    final serverUrl = ref.read(serverConfigProvider);
    await ref.read(mqttConfigProvider.notifier).deriveFromServerUrl(serverUrl);
    final config = ref.read(mqttConfigProvider);
    _hostController.text = config.host;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Broker MQTT dérivé du serveur: ${config.host}'),
          backgroundColor: const Color(0xFF606C38),
        ),
      );
      _checkConnection();
    }
  }

  String? _validateHost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer l\'adresse du broker';
    }
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port requis';
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Port invalide (1-65535)';
    }
    return null;
  }

  Widget _buildStatusIcon() {
    switch (_connectionStatus) {
      case MqttConnectionStatus.checking:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MqttConnectionStatus.connected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case MqttConnectionStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case MqttConnectionStatus.unknown:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(mqttConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration MQTT'),
        actions: [
          IconButton(
            icon: _connectionStatus == MqttConnectionStatus.checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _connectionStatus == MqttConnectionStatus.checking
                ? null
                : _checkConnection,
            tooltip: 'Tester la connexion',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ces paramètres seront envoyés aux appareils lors de l\'appairage.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: _buildStatusIcon(),
                  title: Text(
                    _connectionStatus == MqttConnectionStatus.connected
                        ? 'Connecté au broker MQTT'
                        : _connectionStatus == MqttConnectionStatus.checking
                            ? 'Test de connexion...'
                            : _connectionStatus == MqttConnectionStatus.failed
                                ? 'Connexion échouée'
                                : 'État inconnu',
                  ),
                  subtitle: _connectionError != null
                      ? Text(
                          _connectionError!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : Text('${config.host}:${config.port}'),
                ),
              ),
              const SizedBox(height: 24),
              Text('Broker MQTT', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse du broker',
                        hintText: '192.168.1.100',
                        prefixIcon: Icon(Icons.dns),
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: _validateHost,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '1883',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                      validator: _validatePort,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Authentification', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  hintText: 'plantnanny_device',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                enabled: _isEditing,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('MQTT activé'),
                subtitle: const Text('Les appareils utiliseront MQTT pour communiquer'),
                value: config.enabled,
                onChanged: (value) {
                  ref.read(mqttConfigProvider.notifier).setEnabled(value);
                },
              ),
              const SizedBox(height: 24),
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          final currentConfig = ref.read(mqttConfigProvider);
                          _hostController.text = currentConfig.host;
                          _portController.text = currentConfig.port.toString();
                          _usernameController.text = currentConfig.username;
                          _passwordController.text = currentConfig.password;
                        },
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveConfig,
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _deriveFromServer,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Dériver du serveur'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.restore),
                    label: const Text('Réinitialiser'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
