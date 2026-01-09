import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/devices/devices_page.dart';
import 'features/devices/add_plant_page.dart';
import 'features/devices/add_device_bluetooth_page.dart';
import 'features/history/history_page.dart';
import 'data/repositories/devices_repository_fake.dart';
import 'data/repositories/devices_repository.dart';

import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/main_page.dart';
import 'data/auth/auth_notifier.dart';
import 'data/repositories/readings_repository.dart';
import 'data/repositories/readings_repository_fake.dart';
import 'data/repositories/commands_repository.dart';
import 'data/repositories/commands_repository_base.dart';
import 'data/repositories/commands_repository_fake.dart';

const bool useFakeReadings = true;
const bool useFakeDevices = true; // Set to true for local development to avoid hitting the server

void main() {
  runApp(ProviderScope(
    overrides: [
      if (useFakeReadings)
        // Use the fake implementation during development
        readingsRepositoryProvider.overrideWithProvider(
          Provider<ReadingsRepository>((_) => FakeReadingsRepository()),
        ),
      if (useFakeDevices)
        // Use a fake devices repo for local development (no server required)
        devicesRepositoryProvider.overrideWithProvider(
          Provider((_) => FakeDevicesRepository()),
        ),
      if (useFakeDevices)
        // Use fake commands as well when using fake devices (local dev)
        commandsRepositoryProvider.overrideWithProvider(
          Provider<CommandsRepositoryBase>((_) => FakeCommandsRepository()),
        ),
    ],
    child: const PlantNannyApp(),
  ));
}

class PlantNannyApp extends ConsumerWidget {
  const PlantNannyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Couleurs modernes vert/gris/blanc
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50), // Vert moderne
      brightness: Brightness.light,
      secondary: const Color(0xFF78909C), // Gris bleuté
    );

    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Gris très clair / blanc cassé
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'PlantNanny',
      theme: theme,
      onGenerateRoute: (settings) {
        // Route avec argument pour la configuration après Bluetooth
        if (settings.name == '/devices/configure') {
          final deviceId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => AddPlantPage(deviceId: deviceId),
          );
        }
        // Route pour l'historique avec deviceId
        if (settings.name == '/history') {
          final deviceId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => HistoryPage(deviceId: deviceId),
          );
        }
        return null;
      },
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/main': (_) => const MainPage(),
        '/devices': (_) => const DevicesPage(),
        '/devices/add': (_) => const AddPlantPage(),
        '/devices/add-bluetooth': (_) => const AddDeviceBluetoothPage(),
      },
      // Show MainPage when signed in, otherwise LoginPage. Keep DevicesPage route available.
      home: authState.isSignedIn ? const MainPage() : const LoginPage(),
    );
  }
}
