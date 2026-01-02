//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'v1_devices_device_id_ota_post_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class V1DevicesDeviceIdOtaPostRequest {
  /// Returns a new [V1DevicesDeviceIdOtaPostRequest] instance.
  V1DevicesDeviceIdOtaPostRequest({

     this.version,
  });

  @JsonKey(
    
    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final String? version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is V1DevicesDeviceIdOtaPostRequest &&
      other.version == version;

    @override
    int get hashCode =>
        version.hashCode;

  factory V1DevicesDeviceIdOtaPostRequest.fromJson(Map<String, dynamic> json) => _$V1DevicesDeviceIdOtaPostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$V1DevicesDeviceIdOtaPostRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

