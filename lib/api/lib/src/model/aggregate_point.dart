//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aggregate_point.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AggregatePoint {
  /// Returns a new [AggregatePoint] instance.
  AggregatePoint({

    required  this.ts,

     this.temperatureCAvg,

     this.humidityPctAvg,

     this.luminosityPctAvg,

     this.temperatureCMin,

     this.temperatureCMax,
  });

  @JsonKey(
    
    name: r'ts',
    required: true,
    includeIfNull: false,
  )


  final DateTime ts;



  @JsonKey(
    
    name: r'temperatureC_avg',
    required: false,
    includeIfNull: false,
  )


  final num? temperatureCAvg;



  @JsonKey(
    
    name: r'humidityPct_avg',
    required: false,
    includeIfNull: false,
  )


  final num? humidityPctAvg;



  @JsonKey(
    
    name: r'luminosityPct_avg',
    required: false,
    includeIfNull: false,
  )


  final num? luminosityPctAvg;



  @JsonKey(
    
    name: r'temperatureC_min',
    required: false,
    includeIfNull: false,
  )


  final num? temperatureCMin;



  @JsonKey(
    
    name: r'temperatureC_max',
    required: false,
    includeIfNull: false,
  )


  final num? temperatureCMax;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AggregatePoint &&
      other.ts == ts &&
      other.temperatureCAvg == temperatureCAvg &&
      other.humidityPctAvg == humidityPctAvg &&
      other.luminosityPctAvg == luminosityPctAvg &&
      other.temperatureCMin == temperatureCMin &&
      other.temperatureCMax == temperatureCMax;

    @override
    int get hashCode =>
        ts.hashCode +
        temperatureCAvg.hashCode +
        humidityPctAvg.hashCode +
        luminosityPctAvg.hashCode +
        temperatureCMin.hashCode +
        temperatureCMax.hashCode;

  factory AggregatePoint.fromJson(Map<String, dynamic> json) => _$AggregatePointFromJson(json);

  Map<String, dynamic> toJson() => _$AggregatePointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

