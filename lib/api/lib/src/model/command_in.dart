//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/command_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'command_in.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommandIn {
  /// Returns a new [CommandIn] instance.
  CommandIn({

    required  this.type,

     this.durationMs,

     this.amountMl,

     this.requestedBy,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final CommandType type;



      /// Pump run duration in milliseconds (recommended for pump control)
          // minimum: 0
  @JsonKey(
    
    name: r'durationMs',
    required: false,
    includeIfNull: false,
  )


  final int? durationMs;



      /// Optional target amount in ml (if you can measure/estimate flow)
          // minimum: 0
  @JsonKey(
    
    name: r'amountMl',
    required: false,
    includeIfNull: false,
  )


  final num? amountMl;



      /// Optional (server may fill with user uid)
  @JsonKey(
    
    name: r'requestedBy',
    required: false,
    includeIfNull: false,
  )


  final String? requestedBy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommandIn &&
      other.type == type &&
      other.durationMs == durationMs &&
      other.amountMl == amountMl &&
      other.requestedBy == requestedBy;

    @override
    int get hashCode =>
        type.hashCode +
        durationMs.hashCode +
        amountMl.hashCode +
        requestedBy.hashCode;

  factory CommandIn.fromJson(Map<String, dynamic> json) => _$CommandInFromJson(json);

  Map<String, dynamic> toJson() => _$CommandInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

