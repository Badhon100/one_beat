import '../../../../core/result/result.dart';
import '../entities/media_track.dart';
import '../repositories/local_audio_repository.dart';

class PickLocalTracks {
  const PickLocalTracks(this._repository);
  final LocalAudioRepository _repository;

  Future<Result<List<MediaTrack>>> call() => _repository.pickTracks();
}
