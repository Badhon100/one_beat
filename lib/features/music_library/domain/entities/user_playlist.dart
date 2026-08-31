class UserPlaylist {
  const UserPlaylist({
    required this.id,
    required this.name,
    required this.createdAt,
    this.description = '',
    this.colorValue = 0xFF6D5DFB,
    this.trackIds = const [],
  });

  final String id;
  final String name;
  final String description;
  final int colorValue;
  final DateTime createdAt;
  final List<String> trackIds;

  UserPlaylist copyWith({List<String>? trackIds}) {
    return UserPlaylist(
      id: id,
      name: name,
      description: description,
      colorValue: colorValue,
      createdAt: createdAt,
      trackIds: trackIds ?? this.trackIds,
    );
  }
}
