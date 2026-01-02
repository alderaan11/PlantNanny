//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'command_ack.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommandAck {
  /// Returns a new [CommandAck] instance.
  CommandAck({

    required  this.status,

     this.errorMessage,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CommandAckStatusEnum status;



  @JsonKey(
    
    name: r'errorMessage',
    required: false,
    includeIfNull: false,
  )


  final String? errorMessage;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommandAck &&
      other.status == status &&
      other.errorMessage == errorMessage;

    @override
    int get hashCode =>
        status.hashCode +
        errorMessage.hashCode;

  factory CommandAck.fromJson(Map<String, dynamic> json) => _$CommandAckFromJson(json);

  Map<String, dynamic> toJson() => _$CommandAckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CommandAckStatusEnum {
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const CommandAckStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


