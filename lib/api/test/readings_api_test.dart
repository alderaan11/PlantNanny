import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for ReadingsApi
void main() {
  final instance = PlantNannyApi().getReadingsApi();

  group(ReadingsApi, () {
    // Aggregate readings for charts (optional but useful)
    //
    // Retourne des buckets pour graphe (ex: moyenne par 5min/1h). Permet d'éviter de télécharger des milliers de points. 
    //
    //Future<AggregateSeries> v1DevicesDeviceIdReadingsAggregateGet(String deviceId, DateTime from, DateTime to, String bucket) async
    test('test v1DevicesDeviceIdReadingsAggregateGet', () async {
      // TODO
    });

    // Query readings history (Flutter)
    //
    //Future<ReadingList> v1DevicesDeviceIdReadingsGet(String deviceId, { DateTime from, DateTime to, int limit, String order }) async
    test('test v1DevicesDeviceIdReadingsGet', () async {
      // TODO
    });

    // Get last reading
    //
    //Future<Reading> v1DevicesDeviceIdReadingsLastGet(String deviceId) async
    test('test v1DevicesDeviceIdReadingsLastGet', () async {
      // TODO
    });

    // Ingest a sensor reading (ESP32)
    //
    //Future<Reading> v1DevicesDeviceIdReadingsPost(String deviceId, ReadingIn readingIn) async
    test('test v1DevicesDeviceIdReadingsPost', () async {
      // TODO
    });

  });
}
