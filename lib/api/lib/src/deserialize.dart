import 'package:plant_nanny_api/src/model/aggregate_point.dart';
import 'package:plant_nanny_api/src/model/aggregate_series.dart';
import 'package:plant_nanny_api/src/model/command.dart';
import 'package:plant_nanny_api/src/model/command_ack.dart';
import 'package:plant_nanny_api/src/model/command_in.dart';
import 'package:plant_nanny_api/src/model/command_list.dart';
import 'package:plant_nanny_api/src/model/device.dart';
import 'package:plant_nanny_api/src/model/device_list.dart';
import 'package:plant_nanny_api/src/model/device_status.dart';
import 'package:plant_nanny_api/src/model/error.dart';
import 'package:plant_nanny_api/src/model/reading.dart';
import 'package:plant_nanny_api/src/model/reading_in.dart';
import 'package:plant_nanny_api/src/model/reading_list.dart';
import 'package:plant_nanny_api/src/model/register_device_request.dart';
import 'package:plant_nanny_api/src/model/update_device_request.dart';
import 'package:plant_nanny_api/src/model/user_profile.dart';
import 'package:plant_nanny_api/src/model/v1_devices_device_id_ota_post_request.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AggregatePoint':
          return AggregatePoint.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AggregateSeries':
          return AggregateSeries.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Command':
          return Command.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommandAck':
          return CommandAck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommandIn':
          return CommandIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommandList':
          return CommandList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommandStatus':
          
          
        case 'CommandType':
          
          
        case 'Device':
          return Device.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceList':
          return DeviceList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceStatus':
          return DeviceStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Error':
          return Error.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reading':
          return Reading.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReadingIn':
          return ReadingIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReadingList':
          return ReadingList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterDeviceRequest':
          return RegisterDeviceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateDeviceRequest':
          return UpdateDeviceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserProfile':
          return UserProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'V1DevicesDeviceIdOtaPostRequest':
          return V1DevicesDeviceIdOtaPostRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }