// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceListCWProxy {
  DeviceList count(int count);

  DeviceList items(List<Device> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceList(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceList call({
    int count,
    List<Device> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceList.copyWith.fieldName(...)`
class _$DeviceListCWProxyImpl implements _$DeviceListCWProxy {
  const _$DeviceListCWProxyImpl(this._value);

  final DeviceList _value;

  @override
  DeviceList count(int count) => this(count: count);

  @override
  DeviceList items(List<Device> items) => this(items: items);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceList(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return DeviceList(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Device>,
    );
  }
}

extension $DeviceListCopyWith on DeviceList {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceList.copyWith(...)` or like so:`instanceOfDeviceList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceListCWProxy get copyWith => _$DeviceListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceList _$DeviceListFromJson(Map<String, dynamic> json) => $checkedCreate(
      'DeviceList',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['count', 'items'],
        );
        final val = DeviceList(
          count: $checkedConvert('count', (v) => (v as num).toInt()),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>)
                  .map((e) => Device.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$DeviceListToJson(DeviceList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
