import '../../domain/entities/user_playlist.dart';

class UserPlaylistModel {
  const UserPlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colorValue,
    required this.createdAt,
    required this.trackIds,
  });

  factory UserPlaylistModel.fromEntity(UserPlaylist playlist) =>
      UserPlaylistModel(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        colorValue: playlist.colorValue,
        createdAt: playlist.createdAt.toIso8601String(),
        trackIds: playlist.trackIds,
      );

  factory UserPlaylistModel.fromJson(Map<String, Object?> json) =>
      UserPlaylistModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        colorValue: json['colorValue'] as int? ?? 0xFF6D5DFB,
        createdAt: json['createdAt'] as String,
        trackIds: (json['trackIds'] as List<Object?>? ?? const [])
            .cast<String>(),
      );

  final String id;
  final String name;
  final String description;
  final int colorValue;
  final String createdAt;
  final List<String> trackIds;

  UserPlaylist toEntity() => UserPlaylist(
    id: id,
    name: name,
    description: description,
    colorValue: colorValue,
    createdAt: DateTime.parse(createdAt),
    trackIds: trackIds,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'colorValue': colorValue,
    'createdAt': createdAt,
    'trackIds': trackIds,
  };
}
