// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommandCWProxy {
  Command id(String id);

  Command deviceId(String deviceId);

  Command type(CommandType type);

  Command status(CommandStatus status);

  Command createdAt(DateTime createdAt);

  Command updatedAt(DateTime? updatedAt);

  Command durationMs(int? durationMs);

  Command amountMl(num? amountMl);

  Command errorMessage(String? errorMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Command(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Command(...).copyWith(id: 12, name: "My name")
  /// ````
  Command call({
    String id,
    String deviceId,
    CommandType type,
    CommandStatus status,
    DateTime createdAt,
    DateTime? updatedAt,
    int? durationMs,
    num? amountMl,
    String? errorMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommand.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommand.copyWith.fieldName(...)`
class _$CommandCWProxyImpl implements _$CommandCWProxy {
  const _$CommandCWProxyImpl(this._value);

  final Command _value;

  @override
  Command id(String id) => this(id: id);

  @override
  Command deviceId(String deviceId) => this(deviceId: deviceId);

  @override
  Command type(CommandType type) => this(type: type);

  @override
  Command status(CommandStatus status) => this(status: status);

  @override
  Command createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Command updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  Command durationMs(int? durationMs) => this(durationMs: durationMs);

  @override
  Command amountMl(num? amountMl) => this(amountMl: amountMl);

  @override
  Command errorMessage(String? errorMessage) =>
      this(errorMessage: errorMessage);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Command(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Command(...).copyWith(id: 12, name: "My name")
  /// ````
  Command call({
    Object? id = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? amountMl = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
  }) {
    return Command(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CommandType,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CommandStatus,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int?,
      amountMl: amountMl == const $CopyWithPlaceholder()
          ? _value.amountMl
          // ignore: cast_nullable_to_non_nullable
          : amountMl as num?,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
    );
  }
}

extension $CommandCopyWith on Command {
  /// Returns a callable class that can be used as follows: `instanceOfCommand.copyWith(...)` or like so:`instanceOfCommand.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommandCWProxy get copyWith => _$CommandCWProxyImpl(this);
}
