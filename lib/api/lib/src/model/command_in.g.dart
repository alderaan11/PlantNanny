// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_in.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommandInCWProxy {
  CommandIn type(CommandType type);

  CommandIn durationMs(int? durationMs);

  CommandIn amountMl(num? amountMl);

  CommandIn requestedBy(String? requestedBy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandIn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandIn(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandIn call({
    CommandType type,
    int? durationMs,
    num? amountMl,
    String? requestedBy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommandIn.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommandIn.copyWith.fieldName(...)`
class _$CommandInCWProxyImpl implements _$CommandInCWProxy {
  const _$CommandInCWProxyImpl(this._value);

  final CommandIn _value;

  @override
  CommandIn type(CommandType type) => this(type: type);

  @override
  CommandIn durationMs(int? durationMs) => this(durationMs: durationMs);

  @override
  CommandIn amountMl(num? amountMl) => this(amountMl: amountMl);

  @override
  CommandIn requestedBy(String? requestedBy) => this(requestedBy: requestedBy);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandIn(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandIn(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandIn call({
    Object? type = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? amountMl = const $CopyWithPlaceholder(),
    Object? requestedBy = const $CopyWithPlaceholder(),
  }) {
    return CommandIn(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CommandType,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int?,
      amountMl: amountMl == const $CopyWithPlaceholder()
          ? _value.amountMl
          // ignore: cast_nullable_to_non_nullable
          : amountMl as num?,
      requestedBy: requestedBy == const $CopyWithPlaceholder()
          ? _value.requestedBy
          // ignore: cast_nullable_to_non_nullable
          : requestedBy as String?,
    );
  }
}

extension $CommandInCopyWith on CommandIn {
  /// Returns a callable class that can be used as follows: `instanceOfCommandIn.copyWith(...)` or like so:`instanceOfCommandIn.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommandInCWProxy get copyWith => _$CommandInCWProxyImpl(this);
}
