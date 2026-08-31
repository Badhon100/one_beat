import '../../../../core/result/result.dart';
import '../entities/media_track.dart';

abstract interface class LocalAudioRepository {
  Future<Result<List<MediaTrack>>> pickTracks();
}
