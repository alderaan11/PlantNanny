// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegisterDeviceRequestCWProxy {
  RegisterDeviceRequest pairingCode(String pairingCode);

  RegisterDeviceRequest name(String? name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterDeviceRequest call({
    String pairingCode,
    String? name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegisterDeviceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRegisterDeviceRequest.copyWith.fieldName(...)`
class _$RegisterDeviceRequestCWProxyImpl
    implements _$RegisterDeviceRequestCWProxy {
  const _$RegisterDeviceRequestCWProxyImpl(this._value);

  final RegisterDeviceRequest _value;

  @override
  RegisterDeviceRequest pairingCode(String pairingCode) =>
      this(pairingCode: pairingCode);

  @override
  RegisterDeviceRequest name(String? name) => this(name: name);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterDeviceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterDeviceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterDeviceRequest call({
    Object? pairingCode = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return RegisterDeviceRequest(
      pairingCode: pairingCode == const $CopyWithPlaceholder()
          ? _value.pairingCode
          // ignore: cast_nullable_to_non_nullable
          : pairingCode as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
    );
  }
}

extension $RegisterDeviceRequestCopyWith on RegisterDeviceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRegisterDeviceRequest.copyWith(...)` or like so:`instanceOfRegisterDeviceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegisterDeviceRequestCWProxy get copyWith =>
      _$RegisterDeviceRequestCWProxyImpl(this);
}
