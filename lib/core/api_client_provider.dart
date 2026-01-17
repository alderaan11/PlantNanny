import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth/auth_notifier.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';
import 'server_config_provider.dart';

final baseUrlProvider = Provider<String>((ref) {
  return ref.watch(serverConfigProvider);
});

final apiClientProvider = Provider<PlantNannyApi>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  final api = PlantNannyApi(basePathOverride: baseUrl);

  final token = ref.watch(authTokenProvider);
  if (token != null && token.isNotEmpty) {
    api.setBearerAuth('FirebaseJwt', token);
  }

  return api;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).token;
});
