import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

/// Base URL for the API server.
/// - Android emulator: use 10.0.2.2 to reach host localhost
/// - iOS simulator / Linux / macOS / Windows: use localhost
/// - Physical device: use your machine's local IP (e.g., 192.168.1.x)
final baseUrlProvider = Provider<String>((_) {
  // Detect platform and use appropriate URL
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    // Android emulator uses 10.0.2.2 to reach host machine
    return 'http://10.0.2.2:8080';
  }
  // Desktop/web/iOS simulator can use localhost
  return 'http://localhost:8080';
});

/// Provider for the current auth token.
/// TODO: Replace with actual Firebase Auth token from user authentication.
final authTokenProvider = Provider<String?>((ref) {
  // Development token - in production, get this from Firebase Auth
  return 'dev-token-user1';
});

final apiClientProvider = Provider<PlantNannyApi>((ref) {
  final api = PlantNannyApi(basePathOverride: ref.watch(baseUrlProvider));

  // Set the bearer auth token for FirebaseJwt security scheme
  final token = ref.watch(authTokenProvider);
  if (token != null) {
    api.setBearerAuth('FirebaseJwt', token);
  }

  return api;
});
