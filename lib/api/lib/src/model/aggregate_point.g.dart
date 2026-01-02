// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aggregate_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AggregatePointCWProxy {
  AggregatePoint ts(DateTime ts);

  AggregatePoint temperatureCAvg(num? temperatureCAvg);

  AggregatePoint humidityPctAvg(num? humidityPctAvg);

  AggregatePoint luminosityPctAvg(num? luminosityPctAvg);

  AggregatePoint temperatureCMin(num? temperatureCMin);

  AggregatePoint temperatureCMax(num? temperatureCMax);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AggregatePoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AggregatePoint(...).copyWith(id: 12, name: "My name")
  /// ````
  AggregatePoint call({
    DateTime ts,
    num? temperatureCAvg,
    num? humidityPctAvg,
    num? luminosityPctAvg,
    num? temperatureCMin,
    num? temperatureCMax,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAggregatePoint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAggregatePoint.copyWith.fieldName(...)`
class _$AggregatePointCWProxyImpl implements _$AggregatePointCWProxy {
  const _$AggregatePointCWProxyImpl(this._value);

  final AggregatePoint _value;

  @override
  AggregatePoint ts(DateTime ts) => this(ts: ts);

  @override
  AggregatePoint temperatureCAvg(num? temperatureCAvg) =>
      this(temperatureCAvg: temperatureCAvg);

  @override
  AggregatePoint humidityPctAvg(num? humidityPctAvg) =>
      this(humidityPctAvg: humidityPctAvg);

  @override
  AggregatePoint luminosityPctAvg(num? luminosityPctAvg) =>
      this(luminosityPctAvg: luminosityPctAvg);

  @override
  AggregatePoint temperatureCMin(num? temperatureCMin) =>
      this(temperatureCMin: temperatureCMin);

  @override
  AggregatePoint temperatureCMax(num? temperatureCMax) =>
      this(temperatureCMax: temperatureCMax);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AggregatePoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AggregatePoint(...).copyWith(id: 12, name: "My name")
  /// ````
  AggregatePoint call({
    Object? ts = const $CopyWithPlaceholder(),
    Object? temperatureCAvg = const $CopyWithPlaceholder(),
    Object? humidityPctAvg = const $CopyWithPlaceholder(),
    Object? luminosityPctAvg = const $CopyWithPlaceholder(),
    Object? temperatureCMin = const $CopyWithPlaceholder(),
    Object? temperatureCMax = const $CopyWithPlaceholder(),
  }) {
    return AggregatePoint(
      ts: ts == const $CopyWithPlaceholder()
          ? _value.ts
          // ignore: cast_nullable_to_non_nullable
          : ts as DateTime,
      temperatureCAvg: temperatureCAvg == const $CopyWithPlaceholder()
          ? _value.temperatureCAvg
          // ignore: cast_nullable_to_non_nullable
          : temperatureCAvg as num?,
      humidityPctAvg: humidityPctAvg == const $CopyWithPlaceholder()
          ? _value.humidityPctAvg
          // ignore: cast_nullable_to_non_nullable
          : humidityPctAvg as num?,
      luminosityPctAvg: luminosityPctAvg == const $CopyWithPlaceholder()
          ? _value.luminosityPctAvg
          // ignore: cast_nullable_to_non_nullable
          : luminosityPctAvg as num?,
      temperatureCMin: temperatureCMin == const $CopyWithPlaceholder()
          ? _value.temperatureCMin
          // ignore: cast_nullable_to_non_nullable
          : temperatureCMin as num?,
      temperatureCMax: temperatureCMax == const $CopyWithPlaceholder()
          ? _value.temperatureCMax
          // ignore: cast_nullable_to_non_nullable
          : temperatureCMax as num?,
    );
  }
}

extension $AggregatePointCopyWith on AggregatePoint {
  /// Returns a callable class that can be used as follows: `instanceOfAggregatePoint.copyWith(...)` or like so:`instanceOfAggregatePoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AggregatePointCWProxy get copyWith => _$AggregatePointCWProxyImpl(this);
}
