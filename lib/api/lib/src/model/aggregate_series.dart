//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/aggregate_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aggregate_series.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AggregateSeries {
  /// Returns a new [AggregateSeries] instance.
  AggregateSeries({

    required  this.bucket,

    required  this.from,

    required  this.to,

    required  this.items,
  });

  @JsonKey(
    
    name: r'bucket',
    required: true,
    includeIfNull: false,
  )


  final String bucket;



  @JsonKey(
    
    name: r'from',
    required: true,
    includeIfNull: false,
  )


  final DateTime from;



  @JsonKey(
    
    name: r'to',
    required: true,
    includeIfNull: false,
  )


  final DateTime to;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<AggregatePoint> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AggregateSeries &&
      other.bucket == bucket &&
      other.from == from &&
      other.to == to &&
      other.items == items;

    @override
    int get hashCode =>
        bucket.hashCode +
        from.hashCode +
        to.hashCode +
        items.hashCode;

  factory AggregateSeries.fromJson(Map<String, dynamic> json) => _$AggregateSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$AggregateSeriesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

