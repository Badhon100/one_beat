import '../features/audio_capabilities/data/datasources/audio_platform_data_source.dart';
import '../features/audio_capabilities/data/repositories/audio_capabilities_repository_impl.dart';
import '../features/audio_capabilities/domain/usecases/get_audio_capabilities.dart';
import '../features/audio_capabilities/domain/usecases/open_bluetooth_settings.dart';
import '../features/audio_capabilities/domain/usecases/request_bluetooth_permissions.dart';

class AppDependencies {
  const AppDependencies({
    required this.getAudioCapabilities,
    required this.openBluetoothSettings,
    required this.requestBluetoothPermissions,
  });

  factory AppDependencies.create() {
    const dataSource = MethodChannelAudioPlatformDataSource();
    const repository = AudioCapabilitiesRepositoryImpl(dataSource: dataSource);
    return const AppDependencies(
      getAudioCapabilities: GetAudioCapabilities(repository),
      openBluetoothSettings: OpenBluetoothSettings(repository),
      requestBluetoothPermissions: RequestBluetoothPermissions(repository),
    );
  }

  final GetAudioCapabilities getAudioCapabilities;
  final OpenBluetoothSettings openBluetoothSettings;
  final RequestBluetoothPermissions requestBluetoothPermissions;
}
