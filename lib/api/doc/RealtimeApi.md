# plant_nanny_api.api.RealtimeApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1DevicesDeviceIdStreamGet**](RealtimeApi.md#v1devicesdeviceidstreamget) | **GET** /v1/devices/{deviceId}/stream | Server-Sent Events stream (API-only realtime)


# **v1DevicesDeviceIdStreamGet**
> String v1DevicesDeviceIdStreamGet(deviceId)

Server-Sent Events stream (API-only realtime)

Optionnel si tu utilises déjà Firestore listeners. Flux SSE d'événements: reading, status, commandUpdate. 

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getRealtimeApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)

try {
    final response = api.v1DevicesDeviceIdStreamGet(deviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RealtimeApi->v1DevicesDeviceIdStreamGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 

### Return type

**String**

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

