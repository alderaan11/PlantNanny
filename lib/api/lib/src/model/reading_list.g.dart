// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadingListCWProxy {
  ReadingList count(int count);

  ReadingList items(List<Reading> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingList(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingList call({
    int count,
    List<Reading> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReadingList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReadingList.copyWith.fieldName(...)`
class _$ReadingListCWProxyImpl implements _$ReadingListCWProxy {
  const _$ReadingListCWProxyImpl(this._value);

  final ReadingList _value;

  @override
  ReadingList count(int count) => this(count: count);

  @override
  ReadingList items(List<Reading> items) => this(items: items);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingList(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingList call({
    Object? count = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ReadingList(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Reading>,
    );
  }
}

extension $ReadingListCopyWith on ReadingList {
  /// Returns a callable class that can be used as follows: `instanceOfReadingList.copyWith(...)` or like so:`instanceOfReadingList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadingListCWProxy get copyWith => _$ReadingListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingList _$ReadingListFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ReadingList',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['count', 'items'],
        );
        final val = ReadingList(
          count: $checkedConvert('count', (v) => (v as num).toInt()),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>)
                  .map((e) => Reading.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ReadingListToJson(ReadingList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
