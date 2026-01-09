class DeviceMetadata {
  final String? name;
  final String? plantType;
  final bool isOutdoor;
  final int baseDoseSec;
  final String? comments;

  DeviceMetadata({
    this.name,
    this.plantType,
    this.isOutdoor = false,
    this.baseDoseSec = 5,
    this.comments,
  });

  DeviceMetadata copyWith({String? name, String? plantType, bool? isOutdoor, int? baseDoseSec, String? comments}) {
    return DeviceMetadata(
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      baseDoseSec: baseDoseSec ?? this.baseDoseSec,
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() => 'DeviceMetadata(name: $name, plantType: $plantType, isOutdoor: $isOutdoor, baseDoseSec: $baseDoseSec, comments: $comments)';
}
