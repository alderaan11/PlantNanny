//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/command.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'command_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommandList {
  /// Returns a new [CommandList] instance.
  CommandList({

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


  final List<Command> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommandList &&
      other.count == count &&
      other.items == items;

    @override
    int get hashCode =>
        count.hashCode +
        items.hashCode;

  factory CommandList.fromJson(Map<String, dynamic> json) => _$CommandListFromJson(json);

  Map<String, dynamic> toJson() => _$CommandListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

