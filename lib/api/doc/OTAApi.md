# plant_nanny_api.api.OTAApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1DevicesDeviceIdOtaPost**](OTAApi.md#v1devicesdeviceidotapost) | **POST** /v1/devices/{deviceId}/ota | Request OTA check/update


# **v1DevicesDeviceIdOtaPost**
> Command v1DevicesDeviceIdOtaPost(deviceId, v1DevicesDeviceIdOtaPostRequest)

Request OTA check/update

Typiquement, l'app crée une commande ota_check (ou ota_update) via /commands. Cette route est un raccourci possible. 

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getOTAApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final V1DevicesDeviceIdOtaPostRequest v1DevicesDeviceIdOtaPostRequest = ; // V1DevicesDeviceIdOtaPostRequest | 

try {
    final response = api.v1DevicesDeviceIdOtaPost(deviceId, v1DevicesDeviceIdOtaPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OTAApi->v1DevicesDeviceIdOtaPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **v1DevicesDeviceIdOtaPostRequest** | [**V1DevicesDeviceIdOtaPostRequest**](V1DevicesDeviceIdOtaPostRequest.md)|  | [optional] 

### Return type

[**Command**](Command.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

