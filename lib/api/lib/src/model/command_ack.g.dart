// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_ack.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommandAckCWProxy {
  CommandAck status(CommandAckStatusEnum status);

  CommandAck errorMessage(String? errorMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandAck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandAck(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandAck call({
    CommandAckStatusEnum status,
    String? errorMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommandAck.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommandAck.copyWith.fieldName(...)`
class _$CommandAckCWProxyImpl implements _$CommandAckCWProxy {
  const _$CommandAckCWProxyImpl(this._value);

  final CommandAck _value;

  @override
  CommandAck status(CommandAckStatusEnum status) => this(status: status);

  @override
  CommandAck errorMessage(String? errorMessage) =>
      this(errorMessage: errorMessage);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandAck(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandAck(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandAck call({
    Object? status = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
  }) {
    return CommandAck(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CommandAckStatusEnum,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
    );
  }
}

extension $CommandAckCopyWith on CommandAck {
  /// Returns a callable class that can be used as follows: `instanceOfCommandAck.copyWith(...)` or like so:`instanceOfCommandAck.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommandAckCWProxy get copyWith => _$CommandAckCWProxyImpl(this);
}
