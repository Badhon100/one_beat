import '../../../../core/result/result.dart';
import '../entities/audio_capabilities.dart';

abstract interface class AudioCapabilitiesRepository {
  Future<Result<AudioCapabilities>> getCapabilities();
  Future<Result<bool>> requestBluetoothPermissions();
  Future<Result<void>> openBluetoothSettings();
}
