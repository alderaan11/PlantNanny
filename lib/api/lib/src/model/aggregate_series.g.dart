// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aggregate_series.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AggregateSeriesCWProxy {
  AggregateSeries bucket(String bucket);

  AggregateSeries from(DateTime from);

  AggregateSeries to(DateTime to);

  AggregateSeries items(List<AggregatePoint> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AggregateSeries(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AggregateSeries(...).copyWith(id: 12, name: "My name")
  /// ````
  AggregateSeries call({
    String bucket,
    DateTime from,
    DateTime to,
    List<AggregatePoint> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAggregateSeries.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAggregateSeries.copyWith.fieldName(...)`
class _$AggregateSeriesCWProxyImpl implements _$AggregateSeriesCWProxy {
  const _$AggregateSeriesCWProxyImpl(this._value);

  final AggregateSeries _value;

  @override
  AggregateSeries bucket(String bucket) => this(bucket: bucket);

  @override
  AggregateSeries from(DateTime from) => this(from: from);

  @override
  AggregateSeries to(DateTime to) => this(to: to);

  @override
  AggregateSeries items(List<AggregatePoint> items) => this(items: items);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AggregateSeries(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AggregateSeries(...).copyWith(id: 12, name: "My name")
  /// ````
  AggregateSeries call({
    Object? bucket = const $CopyWithPlaceholder(),
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return AggregateSeries(
      bucket: bucket == const $CopyWithPlaceholder()
          ? _value.bucket
          // ignore: cast_nullable_to_non_nullable
          : bucket as String,
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as DateTime,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as DateTime,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AggregatePoint>,
    );
  }
}

extension $AggregateSeriesCopyWith on AggregateSeries {
  /// Returns a callable class that can be used as follows: `instanceOfAggregateSeries.copyWith(...)` or like so:`instanceOfAggregateSeries.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AggregateSeriesCWProxy get copyWith => _$AggregateSeriesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AggregateSeries _$AggregateSeriesFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AggregateSeries',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['bucket', 'from', 'to', 'items'],
        );
        final val = AggregateSeries(
          bucket: $checkedConvert('bucket', (v) => v as String),
          from: $checkedConvert('from', (v) => DateTime.parse(v as String)),
          to: $checkedConvert('to', (v) => DateTime.parse(v as String)),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>)
                  .map(
                      (e) => AggregatePoint.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$AggregateSeriesToJson(AggregateSeries instance) =>
    <String, dynamic>{
      'bucket': instance.bucket,
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
