//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum CommandType {
      @JsonValue(r'force_reading')
      forceReading(r'force_reading'),
      @JsonValue(r'pump_water')
      pumpWater(r'pump_water'),
      @JsonValue(r'pump_on')
      pumpOn(r'pump_on'),
      @JsonValue(r'pump_off')
      pumpOff(r'pump_off'),
      @JsonValue(r'ota_check')
      otaCheck(r'ota_check'),
      @JsonValue(r'ota_update')
      otaUpdate(r'ota_update');

  const CommandType(this.value);

  final String value;

  @override
  String toString() => value;
}
