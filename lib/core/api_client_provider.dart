import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth/auth_notifier.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

// Si tu as un provider de baseUrl ailleurs, garde ton import réel ici.
// import '../data/auth/auth_notifier.dart';  // <-- seulement si tu en as besoin

/// Exemple : base URL par plateforme (à adapter à ton projet)
final baseUrlProvider = Provider<String>((ref) {
  // Android emulator ne peut pas accéder à localhost du host -> 10.0.2.2
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  // iOS simulator / macOS / web
  return 'http://localhost:8080';
});

/// Le provider principal du client OpenAPI
final apiClientProvider = Provider<PlantNannyApi>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);

  // Selon le générateur, le champ peut s'appeler basePath ou basePathOverride.
  final api = PlantNannyApi(basePathOverride: baseUrl);

  // Watch the auth token and set bearer auth when available.
  // We use watch so the provider will recompute when the token changes.
  final token = ref.watch(authTokenProvider);
  if (token != null && token.isNotEmpty) {
    api.setBearerAuth('FirebaseJwt', token);
  }

  return api;
});


/// Provider for the current auth token.
/// Uses the auth notifier state to obtain the current token.
final authTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.token;
});

