import '../../../../core/result/result.dart';
import '../entities/audio_capabilities.dart';
import '../repositories/audio_capabilities_repository.dart';

class GetAudioCapabilities {
  const GetAudioCapabilities(this._repository);
  final AudioCapabilitiesRepository _repository;

  Future<Result<AudioCapabilities>> call() => _repository.getCapabilities();
}
