import '../../../../core/result/result.dart';
import '../../../music_library/domain/entities/media_track.dart';
import '../entities/player_loop_mode.dart';

abstract interface class AudioPlaybackRepository {
  Stream<bool> get playingStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<int?> get currentIndexStream;
  Stream<bool> get shuffleStream;
  Stream<PlayerLoopMode> get loopModeStream;

  Future<Result<void>> setQueue(List<MediaTrack> tracks, int initialIndex);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> next();
  Future<void> previous();
  Future<void> setShuffle(bool enabled);
  Future<void> setLoopMode(PlayerLoopMode mode);
  Future<void> dispose();
}
