import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/devices/devices_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/main_page.dart';
import 'data/auth/auth_notifier.dart';
import 'data/repositories/readings_repository.dart';
import 'data/repositories/readings_repository_fake.dart';

const bool useFakeReadings = true;

void main() {
  runApp(ProviderScope(
    overrides: [
      if (useFakeReadings)
        // Use the fake implementation during development
        readingsRepositoryProvider.overrideWithProvider(
          Provider<ReadingsRepository>((_) => FakeReadingsRepository()),
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

    return MaterialApp(
      title: 'PlantNanny',
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/main': (_) => const MainPage(),
        '/devices': (_) => const DevicesPage(),
      },
      // Show MainPage when signed in, otherwise LoginPage. Keep DevicesPage route available.
      home: authState.isSignedIn ? const MainPage() : const LoginPage(),
    );
  }
}
