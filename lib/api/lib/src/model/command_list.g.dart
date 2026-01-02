// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommandListCWProxy {
  CommandList count(int count);

  CommandList items(List<Command> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandList(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandList call({
    int count,
    List<Command> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommandList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommandList.copyWith.fieldName(...)`
class _$CommandListCWProxyImpl implements _$CommandListCWProxy {
  const _$CommandListCWProxyImpl(this._value);

  final CommandList _value;

  @override
  CommandList count(int count) => this(count: count);

  @override
  CommandList items(List<Command> items) => this(items: items);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommandList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommandList(...).copyWith(id: 12, name: "My name")
  /// ````
  CommandList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return CommandList(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Command>,
    );
  }
}

extension $CommandListCopyWith on CommandList {
  /// Returns a callable class that can be used as follows: `instanceOfCommandList.copyWith(...)` or like so:`instanceOfCommandList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommandListCWProxy get copyWith => _$CommandListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandList _$CommandListFromJson(Map<String, dynamic> json) => $checkedCreate(
      'CommandList',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['count', 'items'],
        );
        final val = CommandList(
          count: $checkedConvert('count', (v) => (v as num).toInt()),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>)
                  .map((e) => Command.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CommandListToJson(CommandList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
