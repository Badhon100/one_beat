import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../music_library/domain/entities/media_track.dart';
import '../../domain/entities/player_loop_mode.dart';
import '../../domain/repositories/audio_playback_repository.dart';

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
    try {
      await _configureSession();
      final sources = tracks
          .map((track) => AudioSource.file(track.location))
          .toList();
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      return const Success(null);
    } on Object catch (error) {
      return Failure(
        AppFailure('This audio file could not be played.', cause: error),
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
  Future<void> setLoopMode(PlayerLoopMode mode) {
    return _player.setLoopMode(switch (mode) {
      PlayerLoopMode.off => LoopMode.off,
      PlayerLoopMode.one => LoopMode.one,
      PlayerLoopMode.all => LoopMode.all,
    });
  }

  @override
  Future<void> dispose() => _player.dispose();
}
