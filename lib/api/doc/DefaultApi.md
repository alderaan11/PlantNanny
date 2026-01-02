# plant_nanny_api.api.DefaultApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthGet**](DefaultApi.md#healthget) | **GET** /health | Health check


# **healthGet**
> String healthGet()

Health check

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDefaultApi();

try {
    final response = api.healthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->healthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/plain

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

