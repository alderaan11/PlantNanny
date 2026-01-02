import 'package:test/test.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';


/// tests for AuthApi
void main() {
  final instance = PlantNannyApi().getAuthApi();

  group(AuthApi, () {
    // Get current user profile (from token)
    //
    //Future<UserProfile> v1MeGet() async
    test('test v1MeGet', () async {
      // TODO
    });

  });
}
