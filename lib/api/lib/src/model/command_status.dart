//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum CommandStatus {
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'sent')
      sent(r'sent'),
      @JsonValue(r'done')
      done(r'done'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'canceled')
      canceled(r'canceled');

  const CommandStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
