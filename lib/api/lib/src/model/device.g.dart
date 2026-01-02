// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceCWProxy {
  Device deviceId(String deviceId);

  Device name(String? name);

  Device ownerUid(String? ownerUid);

  Device createdAt(DateTime createdAt);

  Device lastSeen(DateTime? lastSeen);

  Device firmwareVersion(String? firmwareVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Device(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Device(...).copyWith(id: 12, name: "My name")
  /// ````
  Device call({
    String deviceId,
    String? name,
    String? ownerUid,
    DateTime createdAt,
    DateTime? lastSeen,
    String? firmwareVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDevice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDevice.copyWith.fieldName(...)`
class _$DeviceCWProxyImpl implements _$DeviceCWProxy {
  const _$DeviceCWProxyImpl(this._value);

  final Device _value;

  @override
  Device deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  Device name(String? name) => this(name: name);

  @override
  Device ownerUid(String? ownerUid) => this(ownerUid: ownerUid);

  @override
  Device createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Device lastSeen(DateTime? lastSeen) => this(lastSeen: lastSeen);

  @override
  Device firmwareVersion(String? firmwareVersion) =>
      this(firmwareVersion: firmwareVersion);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Device(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Device(...).copyWith(id: 12, name: "My name")
  /// ````
  Device call({
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? ownerUid = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? lastSeen = const $CopyWithPlaceholder(),
    Object? firmwareVersion = const $CopyWithPlaceholder(),
  }) {
    return Device(
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      ownerUid: ownerUid == const $CopyWithPlaceholder()
          ? _value.ownerUid
          // ignore: cast_nullable_to_non_nullable
          : ownerUid as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      lastSeen: lastSeen == const $CopyWithPlaceholder()
          ? _value.lastSeen
          // ignore: cast_nullable_to_non_nullable
          : lastSeen as DateTime?,
      firmwareVersion: firmwareVersion == const $CopyWithPlaceholder()
          ? _value.firmwareVersion
          // ignore: cast_nullable_to_non_nullable
          : firmwareVersion as String?,
    );
  }
}

extension $DeviceCopyWith on Device {
  /// Returns a callable class that can be used as follows: `instanceOfDevice.copyWith(...)` or like so:`instanceOfDevice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceCWProxy get copyWith => _$DeviceCWProxyImpl(this);
}
