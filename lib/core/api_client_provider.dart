import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

final baseUrlProvider = Provider<String>((_) => 'http://192.168.1.20:8080');

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: ref.watch(baseUrlProvider)));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(dio: ref.watch(dioProvider));
});
