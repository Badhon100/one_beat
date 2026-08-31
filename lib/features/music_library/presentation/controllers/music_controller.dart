import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../../audio_player/domain/entities/player_loop_mode.dart';
import '../../../audio_player/domain/repositories/audio_playback_repository.dart';
import '../../domain/entities/media_track.dart';
import '../../domain/entities/music_library.dart';
import '../../domain/entities/user_playlist.dart';
import '../../domain/usecases/load_music_library.dart';
import '../../domain/usecases/parse_youtube_url.dart';
import '../../domain/usecases/pick_local_tracks.dart';
import '../../domain/usecases/save_music_library.dart';

class MusicController extends ChangeNotifier {
  MusicController({
    required LoadMusicLibrary loadLibrary,
    required SaveMusicLibrary saveLibrary,
    required PickLocalTracks pickLocalTracks,
    required ParseYoutubeUrl parseYoutubeUrl,
    required AudioPlaybackRepository playback,
  }) : _loadLibrary = loadLibrary,
       _saveLibrary = saveLibrary,
       _pickLocalTracks = pickLocalTracks,
       _parseYoutubeUrl = parseYoutubeUrl,
       _playback = playback;

  final LoadMusicLibrary _loadLibrary;
  final SaveMusicLibrary _saveLibrary;
  final PickLocalTracks _pickLocalTracks;
  final ParseYoutubeUrl _parseYoutubeUrl;
  final AudioPlaybackRepository _playback;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  MusicLibrary library = const MusicLibrary();
  List<MediaTrack> queue = const [];
  bool isLoading = true;
  bool isPlaying = false;
  bool shuffleEnabled = false;
  PlayerLoopMode loopMode = PlayerLoopMode.off;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  int? currentIndex;
  String? errorMessage;

  MediaTrack? get currentTrack {
    final index = currentIndex;
    return index == null || index < 0 || index >= queue.length
        ? null
        : queue[index];
  }

  List<MediaTrack> get recentTracks {
    final tracks = [...library.tracks]
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return tracks.take(8).toList(growable: false);
  }

  List<MediaTrack> get favoriteTracks =>
      library.tracks.where((track) => track.isFavorite).toList(growable: false);

  Future<void> initialize() async {
    _listenToPlayback();
    final result = await _loadLibrary();
    switch (result) {
      case Success(value: final value):
        library = value;
      case Failure(failure: final failure):
        errorMessage = failure.message;
    }
    isLoading = false;
    notifyListeners();
  }

  void _listenToPlayback() {
    _subscriptions.addAll([
      _playback.playingStream.listen((value) {
        isPlaying = value;
        notifyListeners();
      }),
      _playback.positionStream.listen((value) {
        position = value;
        notifyListeners();
      }),
      _playback.durationStream.listen((value) {
        duration = value ?? Duration.zero;
        notifyListeners();
      }),
      _playback.currentIndexStream.listen((value) {
        currentIndex = value;
        notifyListeners();
      }),
      _playback.shuffleStream.listen((value) {
        shuffleEnabled = value;
        notifyListeners();
      }),
      _playback.loopModeStream.listen((value) {
        loopMode = value;
        notifyListeners();
      }),
    ]);
  }

  Future<String?> importLocalTracks() async {
    final result = await _pickLocalTracks();
    switch (result) {
      case Failure(failure: final failure):
        return failure.message;
      case Success(value: final imported):
        if (imported.isEmpty) return null;
        final existingPaths = library.tracks
            .map((track) => track.location)
            .toSet();
        final unique = imported.where(
          (track) => !existingPaths.contains(track.location),
        );
        library = library.copyWith(tracks: [...library.tracks, ...unique]);
        notifyListeners();
        return _persist();
    }
  }

  Future<String?> addYoutubeTrack({
    required String url,
    required String title,
    required String artist,
    required String category,
  }) async {
    final videoId = _parseYoutubeUrl(url);
    if (videoId == null) return 'Enter a valid YouTube video or Shorts link.';
    if (library.tracks.any((track) => track.youtubeVideoId == videoId)) {
      return 'That YouTube video is already in your library.';
    }
    final track = MediaTrack(
      id: 'youtube_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'YouTube video' : title.trim(),
      artist: artist.trim().isEmpty ? 'YouTube' : artist.trim(),
      location: url.trim(),
      sourceType: MediaSourceType.youtube,
      youtubeVideoId: videoId,
      category: category.trim().isEmpty ? 'Uncategorized' : category.trim(),
      addedAt: DateTime.now(),
    );
    library = library.copyWith(tracks: [...library.tracks, track]);
    notifyListeners();
    return _persist();
  }

  Future<String?> createPlaylist({
    required String name,
    required String description,
    required int colorValue,
  }) async {
    if (name.trim().isEmpty) return 'Give your playlist a name.';
    final playlist = UserPlaylist(
      id: 'playlist_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    library = library.copyWith(playlists: [...library.playlists, playlist]);
    notifyListeners();
    return _persist();
  }

  Future<String?> addTrackToPlaylist(
    MediaTrack track,
    UserPlaylist playlist,
  ) async {
    if (playlist.trackIds.contains(track.id)) return null;
    final updated = playlist.copyWith(
      trackIds: [...playlist.trackIds, track.id],
    );
    library = library.copyWith(
      playlists: library.playlists
          .map((item) => item.id == playlist.id ? updated : item)
          .toList(growable: false),
    );
    notifyListeners();
    return _persist();
  }

  Future<void> toggleFavorite(MediaTrack track) async {
    library = library.copyWith(
      tracks: library.tracks
          .map(
            (item) => item.id == track.id
                ? item.copyWith(isFavorite: !item.isFavorite)
                : item,
          )
          .toList(growable: false),
    );
    notifyListeners();
    await _persist();
  }

  Future<String?> updateCategory(MediaTrack track, String category) async {
    if (category.trim().isEmpty) return 'Category cannot be empty.';
    library = library.copyWith(
      tracks: library.tracks
          .map(
            (item) => item.id == track.id
                ? item.copyWith(category: category.trim())
                : item,
          )
          .toList(growable: false),
    );
    notifyListeners();
    return _persist();
  }

  Future<void> removeTrack(MediaTrack track) async {
    library = library.copyWith(
      tracks: library.tracks.where((item) => item.id != track.id).toList(),
      playlists: library.playlists
          .map(
            (playlist) => playlist.copyWith(
              trackIds: playlist.trackIds
                  .where((id) => id != track.id)
                  .toList(),
            ),
          )
          .toList(),
    );
    notifyListeners();
    await _persist();
  }

  Future<String?> playLocalTrack(
    MediaTrack track, {
    List<MediaTrack>? from,
  }) async {
    final candidates = (from ?? library.tracks)
        .where((item) => item.isLocal)
        .toList();
    final initialIndex = candidates.indexWhere((item) => item.id == track.id);
    if (initialIndex < 0) return 'This local track is no longer available.';
    final result = await _playback.setQueue(candidates, initialIndex);
    switch (result) {
      case Failure(failure: final failure):
        return failure.message;
      case Success():
        queue = candidates;
        currentIndex = initialIndex;
        await _playback.play();
        notifyListeners();
        return null;
    }
  }

  Future<void> togglePlayback() =>
      isPlaying ? _playback.pause() : _playback.play();
  Future<void> pause() => _playback.pause();
  Future<void> seek(Duration value) => _playback.seek(value);
  Future<void> next() => _playback.next();
  Future<void> previous() => _playback.previous();
  Future<void> toggleShuffle() => _playback.setShuffle(!shuffleEnabled);

  Future<void> cycleLoopMode() {
    final nextMode = switch (loopMode) {
      PlayerLoopMode.off => PlayerLoopMode.all,
      PlayerLoopMode.all => PlayerLoopMode.one,
      PlayerLoopMode.one => PlayerLoopMode.off,
    };
    return _playback.setLoopMode(nextMode);
  }

  Future<String?> _persist() async {
    final result = await _saveLibrary(library);
    return switch (result) {
      Success() => null,
      Failure(failure: final failure) => failure.message,
    };
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _playback.dispose();
    super.dispose();
  }
}
