# plant_nanny_api.api.CommandsApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1DevicesDeviceIdCommandsCommandIdAckPost**](CommandsApi.md#v1devicesdeviceidcommandscommandidackpost) | **POST** /v1/devices/{deviceId}/commands/{commandId}:ack | ESP32 acknowledges command execution result
[**v1DevicesDeviceIdCommandsGet**](CommandsApi.md#v1devicesdeviceidcommandsget) | **GET** /v1/devices/{deviceId}/commands | List commands (for UI history/debug)
[**v1DevicesDeviceIdCommandsPendingGet**](CommandsApi.md#v1devicesdeviceidcommandspendingget) | **GET** /v1/devices/{deviceId}/commands/pending | ESP32 polls pending commands
[**v1DevicesDeviceIdCommandsPost**](CommandsApi.md#v1devicesdeviceidcommandspost) | **POST** /v1/devices/{deviceId}/commands | Create a command for a device (force reading, pump, etc.)


# **v1DevicesDeviceIdCommandsCommandIdAckPost**
> Command v1DevicesDeviceIdCommandsCommandIdAckPost(deviceId, commandId, commandAck)

ESP32 acknowledges command execution result

### Example
```dart
import 'package:plant_nanny_api/api.dart';
// TODO Configure API key authorization: DeviceKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKeyPrefix = 'Bearer';

final api = PlantNannyApi().getCommandsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final String commandId = commandId_example; // String | Command identifier
final CommandAck commandAck = {"status":"done"}; // CommandAck | 

try {
    final response = api.v1DevicesDeviceIdCommandsCommandIdAckPost(deviceId, commandId, commandAck);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CommandsApi->v1DevicesDeviceIdCommandsCommandIdAckPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **commandId** | **String**| Command identifier | 
 **commandAck** | [**CommandAck**](CommandAck.md)|  | 

### Return type

[**Command**](Command.md)

### Authorization

[DeviceKey](../README.md#DeviceKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdCommandsGet**
> CommandList v1DevicesDeviceIdCommandsGet(deviceId, limit)

List commands (for UI history/debug)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getCommandsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final int limit = 56; // int | 

try {
    final response = api.v1DevicesDeviceIdCommandsGet(deviceId, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CommandsApi->v1DevicesDeviceIdCommandsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**CommandList**](CommandList.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdCommandsPendingGet**
> CommandList v1DevicesDeviceIdCommandsPendingGet(deviceId, max)

ESP32 polls pending commands

### Example
```dart
import 'package:plant_nanny_api/api.dart';
// TODO Configure API key authorization: DeviceKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKeyPrefix = 'Bearer';

final api = PlantNannyApi().getCommandsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final int max = 56; // int | 

try {
    final response = api.v1DevicesDeviceIdCommandsPendingGet(deviceId, max);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CommandsApi->v1DevicesDeviceIdCommandsPendingGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **max** | **int**|  | [optional] [default to 5]

### Return type

[**CommandList**](CommandList.md)

### Authorization

[DeviceKey](../README.md#DeviceKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdCommandsPost**
> Command v1DevicesDeviceIdCommandsPost(deviceId, commandIn)

Create a command for a device (force reading, pump, etc.)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getCommandsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final CommandIn commandIn = {"type":"force_reading"}; // CommandIn | 

try {
    final response = api.v1DevicesDeviceIdCommandsPost(deviceId, commandIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CommandsApi->v1DevicesDeviceIdCommandsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **commandIn** | [**CommandIn**](CommandIn.md)|  | 

### Return type

[**Command**](Command.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

