//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_device_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDeviceRequest {
  /// Returns a new [RegisterDeviceRequest] instance.
  RegisterDeviceRequest({

    required  this.pairingCode,

     this.name,
  });

      /// Short-lived pairing code obtained from device (via BLE/provisioning)
  @JsonKey(
    
    name: r'pairingCode',
    required: true,
    includeIfNull: false,
  )


  final String pairingCode;



      /// Friendly name for the device
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RegisterDeviceRequest &&
      other.pairingCode == pairingCode &&
      other.name == name;

    @override
    int get hashCode =>
        pairingCode.hashCode +
        name.hashCode;

  factory RegisterDeviceRequest.fromJson(Map<String, dynamic> json) => _$RegisterDeviceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

