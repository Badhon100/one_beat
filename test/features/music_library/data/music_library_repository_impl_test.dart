import 'package:flutter_test/flutter_test.dart';
import 'package:onebeat/core/result/result.dart';
import 'package:onebeat/features/music_library/data/datasources/library_local_data_source.dart';
import 'package:onebeat/features/music_library/data/repositories/music_library_repository_impl.dart';
import 'package:onebeat/features/music_library/domain/entities/media_track.dart';
import 'package:onebeat/features/music_library/domain/entities/music_library.dart';
import 'package:onebeat/features/music_library/domain/entities/user_playlist.dart';

void main() {
  test('persists and restores tracks and playlists', () async {
    final dataSource = _MemoryDataSource();
    final repository = MusicLibraryRepositoryImpl(dataSource);
    final library = MusicLibrary(
      tracks: [
        MediaTrack(
          id: 'track-1',
          title: 'Example',
          artist: 'Artist',
          location: '/music/example.mp3',
          sourceType: MediaSourceType.local,
          addedAt: DateTime.utc(2026),
          category: 'Focus',
          isFavorite: true,
        ),
      ],
      playlists: [
        UserPlaylist(
          id: 'playlist-1',
          name: 'Deep work',
          createdAt: DateTime.utc(2026),
          trackIds: const ['track-1'],
        ),
      ],
    );

    expect(await repository.save(library), isA<Success<void>>());
    final loaded = await repository.load() as Success<MusicLibrary>;

    expect(loaded.value.tracks.single.title, 'Example');
    expect(loaded.value.tracks.single.isFavorite, isTrue);
    expect(loaded.value.playlists.single.trackIds, ['track-1']);
  });
}

class _MemoryDataSource implements LibraryLocalDataSource {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}
