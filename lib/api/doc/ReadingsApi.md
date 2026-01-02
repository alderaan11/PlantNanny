# plant_nanny_api.api.ReadingsApi

## Load the API package
```dart
import 'package:plant_nanny_api/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1DevicesDeviceIdReadingsAggregateGet**](ReadingsApi.md#v1devicesdeviceidreadingsaggregateget) | **GET** /v1/devices/{deviceId}/readings/aggregate | Aggregate readings for charts (optional but useful)
[**v1DevicesDeviceIdReadingsGet**](ReadingsApi.md#v1devicesdeviceidreadingsget) | **GET** /v1/devices/{deviceId}/readings | Query readings history (Flutter)
[**v1DevicesDeviceIdReadingsLastGet**](ReadingsApi.md#v1devicesdeviceidreadingslastget) | **GET** /v1/devices/{deviceId}/readings/last | Get last reading
[**v1DevicesDeviceIdReadingsPost**](ReadingsApi.md#v1devicesdeviceidreadingspost) | **POST** /v1/devices/{deviceId}/readings | Ingest a sensor reading (ESP32)


# **v1DevicesDeviceIdReadingsAggregateGet**
> AggregateSeries v1DevicesDeviceIdReadingsAggregateGet(deviceId, from, to, bucket)

Aggregate readings for charts (optional but useful)

Retourne des buckets pour graphe (ex: moyenne par 5min/1h). Permet d'éviter de télécharger des milliers de points. 

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getReadingsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 
final String bucket = bucket_example; // String | 

try {
    final response = api.v1DevicesDeviceIdReadingsAggregateGet(deviceId, from, to, bucket);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReadingsApi->v1DevicesDeviceIdReadingsAggregateGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **from** | **DateTime**|  | 
 **to** | **DateTime**|  | 
 **bucket** | **String**|  | 

### Return type

[**AggregateSeries**](AggregateSeries.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdReadingsGet**
> ReadingList v1DevicesDeviceIdReadingsGet(deviceId, from, to, limit, order)

Query readings history (Flutter)

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getReadingsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | ISO-8601 datetime (UTC). Inclusive.
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | ISO-8601 datetime (UTC). Exclusive.
final int limit = 56; // int | 
final String order = order_example; // String | 

try {
    final response = api.v1DevicesDeviceIdReadingsGet(deviceId, from, to, limit, order);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReadingsApi->v1DevicesDeviceIdReadingsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **from** | **DateTime**| ISO-8601 datetime (UTC). Inclusive. | [optional] 
 **to** | **DateTime**| ISO-8601 datetime (UTC). Exclusive. | [optional] 
 **limit** | **int**|  | [optional] [default to 200]
 **order** | **String**|  | [optional] [default to 'desc']

### Return type

[**ReadingList**](ReadingList.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdReadingsLastGet**
> Reading v1DevicesDeviceIdReadingsLastGet(deviceId)

Get last reading

### Example
```dart
import 'package:plant_nanny_api/api.dart';

final api = PlantNannyApi().getReadingsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)

try {
    final response = api.v1DevicesDeviceIdReadingsLastGet(deviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReadingsApi->v1DevicesDeviceIdReadingsLastGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 

### Return type

[**Reading**](Reading.md)

### Authorization

[FirebaseJwt](../README.md#FirebaseJwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1DevicesDeviceIdReadingsPost**
> Reading v1DevicesDeviceIdReadingsPost(deviceId, readingIn)

Ingest a sensor reading (ESP32)

### Example
```dart
import 'package:plant_nanny_api/api.dart';
// TODO Configure API key authorization: DeviceKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('DeviceKey').apiKeyPrefix = 'Bearer';

final api = PlantNannyApi().getReadingsApi();
final String deviceId = deviceId_example; // String | Unique device identifier (e.g., esp32-1)
final ReadingIn readingIn = {"temperatureC":22.4,"humidityPct":55.2,"luminosityPct":12.3}; // ReadingIn | 

try {
    final response = api.v1DevicesDeviceIdReadingsPost(deviceId, readingIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReadingsApi->v1DevicesDeviceIdReadingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| Unique device identifier (e.g., esp32-1) | 
 **readingIn** | [**ReadingIn**](ReadingIn.md)|  | 

### Return type

[**Reading**](Reading.md)

### Authorization

[DeviceKey](../README.md#DeviceKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

