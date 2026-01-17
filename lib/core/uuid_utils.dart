/// UUID validation utilities for device identification
///
/// The PlantNanny system uses UUID v4 format for device identification.
/// This file provides validation utilities to ensure device IDs are in
/// the correct format and not the legacy `esp32-{MAC}` format.
library;

/// Validates if a string is a proper UUID v4 format
///
/// UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
/// where x is any hex digit and y is 8, 9, A, or B
///
/// Returns true if the value is a valid UUID v4, false otherwise.
///
/// Example:
/// ```dart
/// isValidUuid('f47ac10b-58cc-4372-a567-0e02b2c3d479'); // true
/// isValidUuid('esp32-abcdef123456'); // false
/// isValidUuid(''); // false
/// ```
bool isValidUuid(String? value) {
  if (value == null || value.isEmpty) return false;
  if (value.length != 36) return false;

  // UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  // where y is 8, 9, A, or B
  final uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  return uuidRegex.hasMatch(value);
}

/// Validates if a string is any valid UUID format (v1-v5)
///
/// More lenient than [isValidUuid], accepts any UUID version.
///
/// Example:
/// ```dart
/// isValidUuidAnyVersion('f47ac10b-58cc-1372-a567-0e02b2c3d479'); // true (v1)
/// isValidUuidAnyVersion('f47ac10b-58cc-4372-a567-0e02b2c3d479'); // true (v4)
/// ```
bool isValidUuidAnyVersion(String? value) {
  if (value == null || value.isEmpty) return false;
  if (value.length != 36) return false;

  final uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  return uuidRegex.hasMatch(value);
}

/// Checks if a device ID is in the legacy `esp32-{MAC}` format
///
/// Legacy format was: `esp32-esp32{MAC_ADDRESS_HEX}`
/// This format should no longer be used. Devices should use UUID v4.
///
/// Returns true if the value appears to be a legacy device ID.
bool isLegacyDeviceId(String? value) {
  if (value == null || value.isEmpty) return false;
  return value.startsWith('esp32-');
}

/// Validates that a device ID is in the correct format
///
/// Returns true if the device ID is a valid UUID and NOT a legacy format.
/// This is the preferred validation method for device IDs.
///
/// Example:
/// ```dart
/// isValidDeviceId('f47ac10b-58cc-4372-a567-0e02b2c3d479'); // true
/// isValidDeviceId('esp32-abcdef123456'); // false
/// isValidDeviceId(''); // false
/// ```
bool isValidDeviceId(String? value) {
  if (value == null || value.isEmpty) return false;
  if (isLegacyDeviceId(value)) return false;
  return isValidUuidAnyVersion(value);
}

/// Extension methods for device ID validation on String
extension DeviceIdValidation on String {
  /// Returns true if this string is a valid UUID v4
  bool get isUuid => isValidUuid(this);

  /// Returns true if this string is a valid UUID of any version
  bool get isUuidAnyVersion => isValidUuidAnyVersion(this);

  /// Returns true if this string is a legacy `esp32-` format device ID
  bool get isLegacyDeviceId => startsWith('esp32-');

  /// Returns true if this string is a valid device ID (UUID, not legacy)
  bool get isValidDeviceId => !isLegacyDeviceId && isUuidAnyVersion;
}
