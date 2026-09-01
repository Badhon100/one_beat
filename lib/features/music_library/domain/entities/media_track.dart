enum MediaSourceType { local }

class MediaTrack {
  const MediaTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.location,
    required this.sourceType,
    required this.addedAt,
    this.category = 'Uncategorized',
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String artist;
  final String location;
  final MediaSourceType sourceType;
  final DateTime addedAt;
  final String category;
  final bool isFavorite;

  bool get isLocal => sourceType == MediaSourceType.local;

  MediaTrack copyWith({
    String? title,
    String? artist,
    String? category,
    bool? isFavorite,
  }) {
    return MediaTrack(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      location: location,
      sourceType: sourceType,
      addedAt: addedAt,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
