import '../../../../core/result/result.dart';
import '../repositories/audio_capabilities_repository.dart';

class OpenBluetoothSettings {
  const OpenBluetoothSettings(this._repository);
  final AudioCapabilitiesRepository _repository;

  Future<Result<void>> call() => _repository.openBluetoothSettings();
}
