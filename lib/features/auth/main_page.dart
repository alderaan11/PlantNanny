import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth/auth_notifier.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantNanny'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          )
        ],
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Bienvenue!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('Token: ${auth.token ?? "(aucun)"}'),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/devices'),
              icon: const Icon(Icons.local_florist),
              label: const Text('Mes plantes'),
            ),
          ),
        ]),
      ),
    );
  }
}
