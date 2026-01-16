import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/devices/devices_page.dart';
import 'features/devices/add_plant_page.dart';
import 'features/devices/add_device_bluetooth_page.dart';
import 'features/history/history_page.dart';
import 'features/settings/server_config_page.dart';

import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/main_page.dart';
import 'data/auth/auth_notifier.dart';
import 'data/auth/firebase_auth_service.dart';
import 'core/server_config_provider.dart';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dart/firebase_dart.dart' as fb_dart;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  if (defaultTargetPlatform == TargetPlatform.linux) {
    // Use pure Dart Firebase for Linux
    fb_dart.FirebaseDart.setup();
    final app = await fb_dart.Firebase.initializeApp(
      options: fb_dart.FirebaseOptions(
        apiKey: DefaultFirebaseOptions.linux.apiKey,
        appId: DefaultFirebaseOptions.linux.appId,
        messagingSenderId: DefaultFirebaseOptions.linux.messagingSenderId,
        projectId: DefaultFirebaseOptions.linux.projectId,
        authDomain: DefaultFirebaseOptions.linux.authDomain,
        storageBucket: DefaultFirebaseOptions.linux.storageBucket,
      ),
    );
    AuthServiceProvider.initialize(FirebaseDartAuthService(app));
  } else {
    // Use standard Firebase for other platforms
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthServiceProvider.initialize(FirebaseAuthService());
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PlantNannyApp(),
    ),
  );
}

class PlantNannyApp extends ConsumerWidget {
  const PlantNannyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF606C38),
      brightness: Brightness.light,
      secondary: const Color(0xFFDDA15E),
    );

    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFEDEDE9),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF606C38),
        foregroundColor: const Color(0xFFEDEDE9),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF606C38),
          foregroundColor: const Color(0xFFEDEDE9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          borderSide: const BorderSide(color: Color(0xFFDDA15E), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF606C38), width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        labelStyle: const TextStyle(fontSize: 16, color: Color(0xFF283618)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF606C38),
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
        '/settings/server': (_) => const ServerConfigPage(),
      },
      home: authState.isSignedIn ? const MainPage() : const LoginPage(),
    );
  }
}
