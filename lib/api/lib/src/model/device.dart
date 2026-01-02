//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Device {
  /// Returns a new [Device] instance.
  Device({

    required  this.deviceId,

     this.name,

     this.ownerUid,

    required  this.createdAt,

     this.lastSeen,

     this.firmwareVersion,
  });

  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'ownerUid',
    required: false,
    includeIfNull: false,
  )


  final String? ownerUid;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'lastSeen',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSeen;



  @JsonKey(
    
    name: r'firmwareVersion',
    required: false,
    includeIfNull: false,
  )


  final String? firmwareVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Device &&
      other.deviceId == deviceId &&
      other.name == name &&
      other.ownerUid == ownerUid &&
      other.createdAt == createdAt &&
      other.lastSeen == lastSeen &&
      other.firmwareVersion == firmwareVersion;

    @override
    int get hashCode =>
        deviceId.hashCode +
        name.hashCode +
        ownerUid.hashCode +
        createdAt.hashCode +
        lastSeen.hashCode +
        firmwareVersion.hashCode;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

