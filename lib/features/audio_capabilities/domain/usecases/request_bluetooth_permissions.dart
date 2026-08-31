import '../../../../core/result/result.dart';
import '../repositories/audio_capabilities_repository.dart';

class RequestBluetoothPermissions {
  const RequestBluetoothPermissions(this._repository);
  final AudioCapabilitiesRepository _repository;

  Future<Result<bool>> call() => _repository.requestBluetoothPermissions();
}
