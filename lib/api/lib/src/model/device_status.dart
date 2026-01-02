//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_status.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceStatus {
  /// Returns a new [DeviceStatus] instance.
  DeviceStatus({

    required  this.deviceId,

    required  this.online,

     this.lastSeen,

     this.wifiRssi,

     this.ip,

     this.firmwareVersion,
  });

  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'online',
    required: true,
    includeIfNull: false,
  )


  final bool online;



  @JsonKey(
    
    name: r'lastSeen',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSeen;



  @JsonKey(
    
    name: r'wifiRssi',
    required: false,
    includeIfNull: false,
  )


  final int? wifiRssi;



  @JsonKey(
    
    name: r'ip',
    required: false,
    includeIfNull: false,
  )


  final String? ip;



  @JsonKey(
    
    name: r'firmwareVersion',
    required: false,
    includeIfNull: false,
  )


  final String? firmwareVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceStatus &&
      other.deviceId == deviceId &&
      other.online == online &&
      other.lastSeen == lastSeen &&
      other.wifiRssi == wifiRssi &&
      other.ip == ip &&
      other.firmwareVersion == firmwareVersion;

    @override
    int get hashCode =>
        deviceId.hashCode +
        online.hashCode +
        lastSeen.hashCode +
        wifiRssi.hashCode +
        ip.hashCode +
        firmwareVersion.hashCode;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => _$DeviceStatusFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

