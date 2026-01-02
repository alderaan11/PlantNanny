//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserProfile {
  /// Returns a new [UserProfile] instance.
  UserProfile({

    required  this.uid,

     this.email,

     this.displayName,
  });

  @JsonKey(
    
    name: r'uid',
    required: true,
    includeIfNull: false,
  )


  final String uid;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserProfile &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        uid.hashCode +
        email.hashCode +
        displayName.hashCode;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

