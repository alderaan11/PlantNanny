import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Durée globale d'arrosage en secondes utilisée par la page Arrosage.
final globalPumpDurationProvider = StateProvider<int>((ref) => 5);
