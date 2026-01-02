// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadingCWProxy {
  Reading id(String id);

  Reading deviceId(String deviceId);

  Reading ts(DateTime ts);

  Reading temperatureC(num temperatureC);

  Reading humidityPct(num humidityPct);

  Reading luminosityPct(num luminosityPct);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reading(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reading(...).copyWith(id: 12, name: "My name")
  /// ````
  Reading call({
    String id,
    String deviceId,
    DateTime ts,
    num temperatureC,
    num humidityPct,
    num luminosityPct,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReading.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReading.copyWith.fieldName(...)`
class _$ReadingCWProxyImpl implements _$ReadingCWProxy {
  const _$ReadingCWProxyImpl(this._value);

  final Reading _value;

  @override
  Reading id(String id) => this(id: id);

  @override
  Reading deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  Reading ts(DateTime ts) => this(ts: ts);

  @override
  Reading temperatureC(num temperatureC) => this(temperatureC: temperatureC);

  @override
  Reading humidityPct(num humidityPct) => this(humidityPct: humidityPct);

  @override
  Reading luminosityPct(num luminosityPct) =>
      this(luminosityPct: luminosityPct);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reading(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reading(...).copyWith(id: 12, name: "My name")
  /// ````
  Reading call({
    Object? id = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? ts = const $CopyWithPlaceholder(),
    Object? temperatureC = const $CopyWithPlaceholder(),
    Object? humidityPct = const $CopyWithPlaceholder(),
    Object? luminosityPct = const $CopyWithPlaceholder(),
  }) {
    return Reading(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      ts: ts == const $CopyWithPlaceholder()
          ? _value.ts
          // ignore: cast_nullable_to_non_nullable
          : ts as DateTime,
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

extension $ReadingCopyWith on Reading {
  /// Returns a callable class that can be used as follows: `instanceOfReading.copyWith(...)` or like so:`instanceOfReading.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadingCWProxy get copyWith => _$ReadingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reading _$ReadingFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Reading',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'deviceId',
            'ts',
            'temperatureC',
            'humidityPct',
            'luminosityPct'
          ],
        );
        final val = Reading(
          id: $checkedConvert('id', (v) => v as String),
          deviceId: $checkedConvert('deviceId', (v) => v as String),
          ts: $checkedConvert('ts', (v) => DateTime.parse(v as String)),
          temperatureC: $checkedConvert('temperatureC', (v) => v as num),
          humidityPct: $checkedConvert('humidityPct', (v) => v as num),
          luminosityPct: $checkedConvert('luminosityPct', (v) => v as num),
        );
        return val;
      },
    );

Map<String, dynamic> _$ReadingToJson(Reading instance) => <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'ts': instance.ts.toIso8601String(),
      'temperatureC': instance.temperatureC,
      'humidityPct': instance.humidityPct,
      'luminosityPct': instance.luminosityPct,
    };
