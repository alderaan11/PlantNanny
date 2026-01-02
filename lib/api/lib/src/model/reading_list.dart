//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/reading.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReadingList {
  /// Returns a new [ReadingList] instance.
  ReadingList({

    required  this.count,

    required  this.items,
  });

  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<Reading> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReadingList &&
      other.count == count &&
      other.items == items;

    @override
    int get hashCode =>
        count.hashCode +
        items.hashCode;

  factory ReadingList.fromJson(Map<String, dynamic> json) => _$ReadingListFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

