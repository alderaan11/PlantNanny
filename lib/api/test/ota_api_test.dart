import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for OTAApi
void main() {
  final instance = PlantNannyApi().getOTAApi();

  group(OTAApi, () {
    // Request OTA check/update
    //
    // Typiquement, l'app crée une commande ota_check (ou ota_update) via /commands. Cette route est un raccourci possible. 
    //
    //Future<Command> v1DevicesDeviceIdOtaPost(String deviceId, { V1DevicesDeviceIdOtaPostRequest v1DevicesDeviceIdOtaPostRequest }) async
    test('test v1DevicesDeviceIdOtaPost', () async {
      // TODO
    });

  });
}
