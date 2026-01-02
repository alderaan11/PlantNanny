# plant_nanny_api.api.DevicesApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1DevicesDeviceIdGet**](DevicesApi.md#v1devicesdeviceidget) | **GET** /v1/devices/{deviceId} | Get device details
[**v1DevicesDeviceIdPatch**](DevicesApi.md#v1devicesdeviceidpatch) | **PATCH** /v1/devices/{deviceId} | Update device (rename, metadata)
[**v1DevicesDeviceIdStatusGet**](DevicesApi.md#v1devicesdeviceidstatusget) | **GET** /v1/devices/{deviceId}/status | Get device status (connectivity, lastSeen, firmware)
[**v1DevicesDeviceIdUnregisterPost**](DevicesApi.md#v1devicesdeviceidunregisterpost) | **POST** /v1/devices/{deviceId}:unregister | Unregister device from current user
[**v1DevicesGet**](DevicesApi.md#v1devicesget) | **GET** /v1/devices | List devices for current user
[**v1DevicesRegisterPost**](DevicesApi.md#v1devicesregisterpost) | **POST** /v1/devices:register | Register (pair) a device to the authenticated user


# **v1DevicesDeviceIdGet**
> Device v1DevicesDeviceIdGet(deviceId)

Get device details

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)

try {
    final response = api.v1DevicesDeviceIdGet(deviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesDeviceIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 

### Return type

[**Device**](Device.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdPatch**
> Device v1DevicesDeviceIdPatch(deviceId, updateDeviceRequest)

Update device (rename, metadata)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final UpdateDeviceRequest updateDeviceRequest = ; // UpdateDeviceRequest | 

try {
    final response = api.v1DevicesDeviceIdPatch(deviceId, updateDeviceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesDeviceIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **updateDeviceRequest** | [**UpdateDeviceRequest**](UpdateDeviceRequest.md)|  | 

### Return type

[**Device**](Device.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdStatusGet**
> DeviceStatus v1DevicesDeviceIdStatusGet(deviceId)

Get device status (connectivity, lastSeen, firmware)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)

try {
    final response = api.v1DevicesDeviceIdStatusGet(deviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesDeviceIdStatusGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 

### Return type

[**DeviceStatus**](DeviceStatus.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdUnregisterPost**
> v1DevicesDeviceIdUnregisterPost(deviceId)

Unregister device from current user

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)

try {
    api.v1DevicesDeviceIdUnregisterPost(deviceId);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesDeviceIdUnregisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 

### Return type

void (empty response body)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesGet**
> DeviceList v1DevicesGet()

List devices for current user

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();

try {
    final response = api.v1DevicesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DeviceList**](DeviceList.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesRegisterPost**
> Device v1DevicesRegisterPost(registerDeviceRequest)

Register (pair) a device to the authenticated user

Utilisé après appairage BLE/provisioning : l'app obtient un pairingCode depuis l'ESP32, puis appelle cette route pour associer le device au user. 

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getDevicesApi();
final RegisterDeviceRequest registerDeviceRequest = {"pairingCode":"ABCD-1234","name":"Mon basilic"}; // RegisterDeviceRequest | 

try {
    final response = api.v1DevicesRegisterPost(registerDeviceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->v1DevicesRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerDeviceRequest** | [**RegisterDeviceRequest**](RegisterDeviceRequest.md)|  | 

### Return type

[**Device**](Device.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

