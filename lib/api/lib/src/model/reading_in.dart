//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading_in.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReadingIn {
  /// Returns a new [ReadingIn] instance.
  ReadingIn({

     this.ts,

    required  this.temperatureC,

    required  this.humidityPct,

    required  this.luminosityPct,
  });

      /// Optional; if omitted, server uses receive time (UTC)
  @JsonKey(
    
    name: r'ts',
    required: false,
    includeIfNull: false,
  )


  final DateTime? ts;



  @JsonKey(
    
    name: r'temperatureC',
    required: true,
    includeIfNull: false,
  )


  final num temperatureC;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'humidityPct',
    required: true,
    includeIfNull: false,
  )


  final num humidityPct;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'luminosityPct',
    required: true,
    includeIfNull: false,
  )


  final num luminosityPct;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReadingIn &&
      other.ts == ts &&
      other.temperatureC == temperatureC &&
      other.humidityPct == humidityPct &&
      other.luminosityPct == luminosityPct;

    @override
    int get hashCode =>
        ts.hashCode +
        temperatureC.hashCode +
        humidityPct.hashCode +
        luminosityPct.hashCode;

  factory ReadingIn.fromJson(Map<String, dynamic> json) => _$ReadingInFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

