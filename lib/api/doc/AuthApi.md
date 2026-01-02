# plant_nanny_api.api.AuthApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1MeGet**](AuthApi.md#v1meget) | **GET** /v1/me | Get current user profile (from token)


# **v1MeGet**
> UserProfile v1MeGet()

Get current user profile (from token)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getAuthApi();

try {
    final response = api.v1MeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->v1MeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

