//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/command_type.dart';
import 'package:plant_nanny_api/src/model/command_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'command.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Command {
  /// Returns a new [Command] instance.
  Command({

    required  this.id,

    required  this.deviceId,

    required  this.type,

    required  this.status,

    required  this.createdAt,

     this.updatedAt,

     this.durationMs,

     this.amountMl,

     this.errorMessage,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'deviceId',
    required: true,
    includeIfNull: false,
  )


  final String deviceId;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final CommandType type;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CommandStatus status;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



  @JsonKey(
    
    name: r'durationMs',
    required: false,
    includeIfNull: false,
  )


  final int? durationMs;



  @JsonKey(
    
    name: r'amountMl',
    required: false,
    includeIfNull: false,
  )


  final num? amountMl;



  @JsonKey(
    
    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Command &&
      other.id == id &&
      other.deviceId == deviceId &&
      other.type == type &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.durationMs == durationMs &&
      other.amountMl == amountMl &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        id.hashCode +
        deviceId.hashCode +
        type.hashCode +
        status.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        durationMs.hashCode +
        amountMl.hashCode +
        errorMessage.hashCode;

  factory Command.fromJson(Map<String, dynamic> json) => _$CommandFromJson(json);

  Map<String, dynamic> toJson() => _$CommandToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

