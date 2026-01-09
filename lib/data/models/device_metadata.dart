class DeviceMetadata {
  final String? name;
  final String? plantType;
  final bool isOutdoor;
  final int baseDoseMs;
  final String? comments;

  DeviceMetadata({
    this.name,
    this.plantType,
    this.isOutdoor = false,
    this.baseDoseMs = 5000,
    this.comments,
  });

  DeviceMetadata copyWith({String? name, String? plantType, bool? isOutdoor, int? baseDoseMs, String? comments}) {
    return DeviceMetadata(
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      baseDoseMs: baseDoseMs ?? this.baseDoseMs,
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() => 'DeviceMetadata(name: $name, plantType: $plantType, isOutdoor: $isOutdoor, baseDoseMs: $baseDoseMs, comments: $comments)';
}
