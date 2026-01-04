import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/devices/devices_page.dart';
import 'features/devices/add_plant_page.dart';
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

    // Green / natural themed color scheme
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.green);

    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6FFF5), // very light green background
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
    );

    return MaterialApp(
      title: 'PlantNanny',
      theme: theme,
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/main': (_) => const MainPage(),
        '/devices': (_) => const DevicesPage(),
        '/devices/add': (_) => const AddPlantPage(),
      },
      // Show MainPage when signed in, otherwise LoginPage. Keep DevicesPage route available.
      home: authState.isSignedIn ? const MainPage() : const LoginPage(),
    );
  }
}
