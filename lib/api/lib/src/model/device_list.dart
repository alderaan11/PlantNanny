//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:plant_nanny_api/src/model/device.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceList {
  /// Returns a new [DeviceList] instance.
  DeviceList({

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


  final List<Device> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceList &&
      other.count == count &&
      other.items == items;

    @override
    int get hashCode =>
        count.hashCode +
        items.hashCode;

  factory DeviceList.fromJson(Map<String, dynamic> json) => _$DeviceListFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

