import '../../domain/entities/media_track.dart';

class MediaTrackModel {
  const MediaTrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.location,
    required this.sourceType,
    required this.addedAt,
    required this.category,
    required this.isFavorite,
    this.youtubeVideoId,
  });

  factory MediaTrackModel.fromEntity(MediaTrack track) => MediaTrackModel(
    id: track.id,
    title: track.title,
    artist: track.artist,
    location: track.location,
    sourceType: track.sourceType.name,
    addedAt: track.addedAt.toIso8601String(),
    category: track.category,
    youtubeVideoId: track.youtubeVideoId,
    isFavorite: track.isFavorite,
  );

  factory MediaTrackModel.fromJson(Map<String, Object?> json) =>
      MediaTrackModel(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String? ?? 'Unknown artist',
        location: json['location'] as String,
        sourceType: json['sourceType'] as String,
        addedAt: json['addedAt'] as String,
        category: json['category'] as String? ?? 'Uncategorized',
        youtubeVideoId: json['youtubeVideoId'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String artist;
  final String location;
  final String sourceType;
  final String addedAt;
  final String category;
  final String? youtubeVideoId;
  final bool isFavorite;

  MediaTrack toEntity() => MediaTrack(
    id: id,
    title: title,
    artist: artist,
    location: location,
    sourceType: MediaSourceType.values.byName(sourceType),
    addedAt: DateTime.parse(addedAt),
    category: category,
    youtubeVideoId: youtubeVideoId,
    isFavorite: isFavorite,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'location': location,
    'sourceType': sourceType,
    'addedAt': addedAt,
    'category': category,
    'youtubeVideoId': youtubeVideoId,
    'isFavorite': isFavorite,
  };
}
