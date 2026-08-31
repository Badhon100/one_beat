import 'dart:convert';

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/music_library.dart';
import '../../domain/repositories/music_library_repository.dart';
import '../datasources/library_local_data_source.dart';
import '../models/media_track_model.dart';
import '../models/user_playlist_model.dart';

class MusicLibraryRepositoryImpl implements MusicLibraryRepository {
  const MusicLibraryRepositoryImpl(this._dataSource);
  final LibraryLocalDataSource _dataSource;

  @override
  Future<Result<MusicLibrary>> load() async {
    try {
      final raw = await _dataSource.read();
      if (raw == null) return const Success(MusicLibrary());
      final json = jsonDecode(raw) as Map<String, Object?>;
      final tracks = (json['tracks'] as List<Object?>? ?? const [])
          .map(
            (item) => MediaTrackModel.fromJson(
              item! as Map<String, Object?>,
            ).toEntity(),
          )
          .toList(growable: false);
      final playlists = (json['playlists'] as List<Object?>? ?? const [])
          .map(
            (item) => UserPlaylistModel.fromJson(
              item! as Map<String, Object?>,
            ).toEntity(),
          )
          .toList(growable: false);
      return Success(MusicLibrary(tracks: tracks, playlists: playlists));
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not load your music library.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> save(MusicLibrary library) async {
    try {
      final payload = jsonEncode({
        'tracks': library.tracks
            .map(MediaTrackModel.fromEntity)
            .map((model) => model.toJson())
            .toList(growable: false),
        'playlists': library.playlists
            .map(UserPlaylistModel.fromEntity)
            .map((model) => model.toJson())
            .toList(growable: false),
      });
      await _dataSource.write(payload);
      return const Success(null);
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not save your music library.', cause: error),
      );
    }
  }
}
