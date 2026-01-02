# plant_nanny_api.model.CommandIn

## Load the model package
```dart
import 'package:plant_nanny_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | [**CommandType**](CommandType.md) |  | 
**durationMs** | **int** | Pump run duration in milliseconds (recommended for pump control) | [optional] 
**amountMl** | **num** | Optional target amount in ml (if you can measure/estimate flow) | [optional] 
**requestedBy** | **String** | Optional (server may fill with user uid) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


