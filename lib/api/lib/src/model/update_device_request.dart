//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_device_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateDeviceRequest {
  /// Returns a new [UpdateDeviceRequest] instance.
  UpdateDeviceRequest({

     this.name,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateDeviceRequest &&
      other.name == name;

    @override
    int get hashCode =>
        name.hashCode;

  factory UpdateDeviceRequest.fromJson(Map<String, dynamic> json) => _$UpdateDeviceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDeviceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

