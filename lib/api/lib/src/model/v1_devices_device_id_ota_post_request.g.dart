// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1_devices_device_id_ota_post_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$V1DevicesDeviceIdOtaPostRequestCWProxy {
  V1DevicesDeviceIdOtaPostRequest version(String? version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `V1DevicesDeviceIdOtaPostRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// V1DevicesDeviceIdOtaPostRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  V1DevicesDeviceIdOtaPostRequest call({
    String? version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfV1DevicesDeviceIdOtaPostRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfV1DevicesDeviceIdOtaPostRequest.copyWith.fieldName(...)`
class _$V1DevicesDeviceIdOtaPostRequestCWProxyImpl
    implements _$V1DevicesDeviceIdOtaPostRequestCWProxy {
  const _$V1DevicesDeviceIdOtaPostRequestCWProxyImpl(this._value);

  final V1DevicesDeviceIdOtaPostRequest _value;

  @override
  V1DevicesDeviceIdOtaPostRequest version(String? version) =>
      this(version: version);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `V1DevicesDeviceIdOtaPostRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// V1DevicesDeviceIdOtaPostRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  V1DevicesDeviceIdOtaPostRequest call({
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return V1DevicesDeviceIdOtaPostRequest(
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String?,
    );
  }
}

extension $V1DevicesDeviceIdOtaPostRequestCopyWith
    on V1DevicesDeviceIdOtaPostRequest {
  /// Returns a callable class that can be used as follows: `instanceOfV1DevicesDeviceIdOtaPostRequest.copyWith(...)` or like so:`instanceOfV1DevicesDeviceIdOtaPostRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$V1DevicesDeviceIdOtaPostRequestCWProxy get copyWith =>
      _$V1DevicesDeviceIdOtaPostRequestCWProxyImpl(this);
}
