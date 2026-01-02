import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for RealtimeApi
void main() {
  final instance = PlantNannyApi().getRealtimeApi();

  group(RealtimeApi, () {
    // Server-Sent Events stream (API-only realtime)
    //
    // Optionnel si tu utilises déjà Firestore listeners. Flux SSE d'événements: reading, status, commandUpdate. 
    //
    //Future<String> v1DevicesDeviceIdStreamGet(String deviceId) async
    test('test v1DevicesDeviceIdStreamGet', () async {
      // TODO
    });

  });
}
