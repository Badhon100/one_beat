import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../music_library/domain/entities/media_track.dart';
import '../../domain/entities/player_loop_mode.dart';
import '../../domain/repositories/audio_playback_repository.dart';

/// Plays local audio only. YouTube media is handled by the visible official
/// YouTube embed, not by extracting or resolving an audio stream.
class JustAudioPlaybackRepository implements AudioPlaybackRepository {
  JustAudioPlaybackRepository() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _sessionConfigured = false;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<bool> get shuffleStream => _player.shuffleModeEnabledStream;

  @override
  Stream<PlayerLoopMode> get loopModeStream => _player.loopModeStream.map(
    (mode) => switch (mode) {
      LoopMode.off => PlayerLoopMode.off,
      LoopMode.one => PlayerLoopMode.one,
      LoopMode.all => PlayerLoopMode.all,
    },
  );

  @override
  Future<Result<void>> setQueue(
    List<MediaTrack> tracks,
    int initialIndex,
  ) async {
    if (tracks.any((track) => !track.isLocal)) {
      return const Failure(
        AppFailure('YouTube videos play in the official embedded player.'),
      );
    }
    try {
      await _configureSession();
      final sources = tracks
          .map(
            (track) => AudioSource.file(
              track.location,
              tag: MediaItem(
                id: track.id,
                album: track.category,
                title: track.title,
                artist: track.artist,
              ),
            ),
          )
          .toList(growable: false);
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      return const Success(null);
    } on Object catch (error) {
      return Failure(
        AppFailure('This local audio file could not be played.', cause: error),
      );
    }
  }

  Future<void> _configureSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> next() => _player.seekToNext();

  @override
  Future<void> previous() => _player.seekToPrevious();

  @override
  Future<void> setShuffle(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  @override
  Future<void> setLoopMode(PlayerLoopMode mode) =>
      _player.setLoopMode(switch (mode) {
        PlayerLoopMode.off => LoopMode.off,
        PlayerLoopMode.one => LoopMode.one,
        PlayerLoopMode.all => LoopMode.all,
      });

  @override
  Future<void> dispose() => _player.dispose();
}
