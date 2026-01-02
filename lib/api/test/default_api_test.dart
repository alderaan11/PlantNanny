import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for DefaultApi
void main() {
  final instance = PlantNannyApi().getDefaultApi();

  group(DefaultApi, () {
    // Health check
    //
    //Future<String> healthGet() async
    test('test healthGet', () async {
      // TODO
    });

  });
}
