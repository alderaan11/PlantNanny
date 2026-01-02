// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_in.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadingInCWProxy {
  ReadingIn ts(DateTime? ts);

  ReadingIn temperatureC(num temperatureC);

  ReadingIn humidityPct(num humidityPct);

  ReadingIn luminosityPct(num luminosityPct);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingIn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingIn(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingIn call({
    DateTime? ts,
    num temperatureC,
    num humidityPct,
    num luminosityPct,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReadingIn.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReadingIn.copyWith.fieldName(...)`
class _$ReadingInCWProxyImpl implements _$ReadingInCWProxy {
  const _$ReadingInCWProxyImpl(this._value);

  final ReadingIn _value;

  @override
  ReadingIn ts(DateTime? ts) => this(ts: ts);

  @override
  ReadingIn temperatureC(num temperatureC) => this(temperatureC: temperatureC);

  @override
  ReadingIn humidityPct(num humidityPct) => this(humidityPct: humidityPct);

  @override
  ReadingIn luminosityPct(num luminosityPct) =>
      this(luminosityPct: luminosityPct);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingIn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingIn(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingIn call({
    Object? ts = const $CopyWithPlaceholder(),
    Object? temperatureC = const $CopyWithPlaceholder(),
    Object? humidityPct = const $CopyWithPlaceholder(),
    Object? luminosityPct = const $CopyWithPlaceholder(),
  }) {
    return ReadingIn(
      ts: ts == const $CopyWithPlaceholder()
          ? _value.ts
          // ignore: cast_nullable_to_non_nullable
          : ts as DateTime?,
      temperatureC: temperatureC == const $CopyWithPlaceholder()
          ? _value.temperatureC
          // ignore: cast_nullable_to_non_nullable
          : temperatureC as num,
      humidityPct: humidityPct == const $CopyWithPlaceholder()
          ? _value.humidityPct
          // ignore: cast_nullable_to_non_nullable
          : humidityPct as num,
      luminosityPct: luminosityPct == const $CopyWithPlaceholder()
          ? _value.luminosityPct
          // ignore: cast_nullable_to_non_nullable
          : luminosityPct as num,
    );
  }
}

extension $ReadingInCopyWith on ReadingIn {
  /// Returns a callable class that can be used as follows: `instanceOfReadingIn.copyWith(...)` or like so:`instanceOfReadingIn.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadingInCWProxy get copyWith => _$ReadingInCWProxyImpl(this);
}
