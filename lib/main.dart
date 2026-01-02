import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/devices/devices_page.dart';

void main() {
  runApp(const ProviderScope(child: PlantNannyApp()));
}

class PlantNannyApp extends StatelessWidget {
  const PlantNannyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantNanny',
      home: const DevicesPage(),
    );
  }
}
