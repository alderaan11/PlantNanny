// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_device_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateDeviceRequestCWProxy {
  UpdateDeviceRequest name(String? name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateDeviceRequest call({
    String? name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateDeviceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateDeviceRequest.copyWith.fieldName(...)`
class _$UpdateDeviceRequestCWProxyImpl implements _$UpdateDeviceRequestCWProxy {
  const _$UpdateDeviceRequestCWProxyImpl(this._value);

  final UpdateDeviceRequest _value;

  @override
  UpdateDeviceRequest name(String? name) => this(name: name);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateDeviceRequest call({
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return UpdateDeviceRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
    );
  }
}

extension $UpdateDeviceRequestCopyWith on UpdateDeviceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateDeviceRequest.copyWith(...)` or like so:`instanceOfUpdateDeviceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateDeviceRequestCWProxy get copyWith =>
      _$UpdateDeviceRequestCWProxyImpl(this);
}
