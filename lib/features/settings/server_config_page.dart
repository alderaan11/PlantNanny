import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/server_config_provider.dart';

class ServerConfigPage extends ConsumerStatefulWidget {
  const ServerConfigPage({super.key});

  @override
  ConsumerState<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends ConsumerState<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current server URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.text = ref.read(serverConfigProvider);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(serverConfigProvider.notifier).setServerUrl(_urlController.text.trim());
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Server configuration section
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'monospace',
                                ),
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
              // Reset button
              Center(
                child: TextButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.restore),
                  label: const Text('Réinitialiser par défaut'),
                ),
              ),
              const SizedBox(height: 32),
              // Help text
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Aide',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
