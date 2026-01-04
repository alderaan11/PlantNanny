import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Durée globale d'arrosage en millisecondes utilisée par la page Arrosage.
final globalPumpDurationProvider = StateProvider<int>((ref) => 5000);
