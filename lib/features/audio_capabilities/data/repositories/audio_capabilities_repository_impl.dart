import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/audio_capabilities.dart';
import '../../domain/repositories/audio_capabilities_repository.dart';
import '../datasources/audio_platform_data_source.dart';

class AudioCapabilitiesRepositoryImpl implements AudioCapabilitiesRepository {
  const AudioCapabilitiesRepositoryImpl({required this.dataSource});
  final AudioPlatformDataSource dataSource;

  @override
  Future<Result<AudioCapabilities>> getCapabilities() async {
    try {
      final model = await dataSource.getCapabilities();
      return Success(model.toEntity());
    } on Object catch (error) {
      return Failure(
        AppFailure(
          'Could not read this device\'s audio capabilities.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> openBluetoothSettings() async {
    try {
      await dataSource.openBluetoothSettings();
      return const Success(null);
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not open Bluetooth settings.', cause: error),
      );
    }
  }

  @override
  Future<Result<bool>> requestBluetoothPermissions() async {
    try {
      return Success(await dataSource.requestBluetoothPermissions());
    } on Object catch (error) {
      return Failure(
        AppFailure('Could not request Bluetooth permission.', cause: error),
      );
    }
  }
}
