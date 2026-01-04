class DeviceMetadata {
  final String? plantType;
  final bool isOutdoor;
  final int baseDoseMs;
  final String? comments;

  DeviceMetadata({
    this.plantType,
    this.isOutdoor = false,
    this.baseDoseMs = 5000,
    this.comments,
  });

  DeviceMetadata copyWith({String? plantType, bool? isOutdoor, int? baseDoseMs, String? comments}) {
    return DeviceMetadata(
      plantType: plantType ?? this.plantType,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      baseDoseMs: baseDoseMs ?? this.baseDoseMs,
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() => 'DeviceMetadata(plantType: $plantType, isOutdoor: $isOutdoor, baseDoseMs: $baseDoseMs, comments: $comments)';
}
