// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceStatusCWProxy {
  DeviceStatus deviceId(String deviceId);

  DeviceStatus online(bool online);

  DeviceStatus lastSeen(DateTime? lastSeen);

  DeviceStatus wifiRssi(int? wifiRssi);

  DeviceStatus ip(String? ip);

  DeviceStatus firmwareVersion(String? firmwareVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceStatus call({
    String deviceId,
    bool online,
    DateTime? lastSeen,
    int? wifiRssi,
    String? ip,
    String? firmwareVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceStatus.copyWith.fieldName(...)`
class _$DeviceStatusCWProxyImpl implements _$DeviceStatusCWProxy {
  const _$DeviceStatusCWProxyImpl(this._value);

  final DeviceStatus _value;

  @override
  DeviceStatus deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  DeviceStatus online(bool online) => this(online: online);

  @override
  DeviceStatus lastSeen(DateTime? lastSeen) => this(lastSeen: lastSeen);

  @override
  DeviceStatus wifiRssi(int? wifiRssi) => this(wifiRssi: wifiRssi);

  @override
  DeviceStatus ip(String? ip) => this(ip: ip);

  @override
  DeviceStatus firmwareVersion(String? firmwareVersion) =>
      this(firmwareVersion: firmwareVersion);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceStatus call({
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? online = const $CopyWithPlaceholder(),
    Object? lastSeen = const $CopyWithPlaceholder(),
    Object? wifiRssi = const $CopyWithPlaceholder(),
    Object? ip = const $CopyWithPlaceholder(),
    Object? firmwareVersion = const $CopyWithPlaceholder(),
  }) {
    return DeviceStatus(
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      online: online == const $CopyWithPlaceholder()
          ? _value.online
          // ignore: cast_nullable_to_non_nullable
          : online as bool,
      lastSeen: lastSeen == const $CopyWithPlaceholder()
          ? _value.lastSeen
          // ignore: cast_nullable_to_non_nullable
          : lastSeen as DateTime?,
      wifiRssi: wifiRssi == const $CopyWithPlaceholder()
          ? _value.wifiRssi
          // ignore: cast_nullable_to_non_nullable
          : wifiRssi as int?,
      ip: ip == const $CopyWithPlaceholder()
          ? _value.ip
          // ignore: cast_nullable_to_non_nullable
          : ip as String?,
      firmwareVersion: firmwareVersion == const $CopyWithPlaceholder()
          ? _value.firmwareVersion
          // ignore: cast_nullable_to_non_nullable
          : firmwareVersion as String?,
    );
  }
}

extension $DeviceStatusCopyWith on DeviceStatus {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceStatus.copyWith(...)` or like so:`instanceOfDeviceStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceStatusCWProxy get copyWith => _$DeviceStatusCWProxyImpl(this);
}
