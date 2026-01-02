//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reading {
  /// Returns a new [Reading] instance.
  Reading({

    required  this.id,

    required  this.deviceId,

    required  this.ts,

    required  this.temperatureC,

    required  this.humidityPct,

    required  this.luminosityPct,
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
    
    name: r'ts',
    required: true,
    includeIfNull: false,
  )


  final DateTime ts;



  @JsonKey(
    
    name: r'temperatureC',
    required: true,
    includeIfNull: false,
  )


  final num temperatureC;



  @JsonKey(
    
    name: r'humidityPct',
    required: true,
    includeIfNull: false,
  )


  final num humidityPct;



  @JsonKey(
    
    name: r'luminosityPct',
    required: true,
    includeIfNull: false,
  )


  final num luminosityPct;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Reading &&
      other.id == id &&
      other.deviceId == deviceId &&
      other.ts == ts &&
      other.temperatureC == temperatureC &&
      other.humidityPct == humidityPct &&
      other.luminosityPct == luminosityPct;

    @override
    int get hashCode =>
        id.hashCode +
        deviceId.hashCode +
        ts.hashCode +
        temperatureC.hashCode +
        humidityPct.hashCode +
        luminosityPct.hashCode;

  factory Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

