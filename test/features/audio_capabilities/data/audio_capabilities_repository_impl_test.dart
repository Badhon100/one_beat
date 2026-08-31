import 'package:flutter_test/flutter_test.dart';
import 'package:onebeat/core/result/result.dart';
import 'package:onebeat/features/audio_capabilities/data/datasources/audio_platform_data_source.dart';
import 'package:onebeat/features/audio_capabilities/data/models/audio_capabilities_model.dart';
import 'package:onebeat/features/audio_capabilities/data/repositories/audio_capabilities_repository_impl.dart';
import 'package:onebeat/features/audio_capabilities/domain/entities/audio_capabilities.dart';

void main() {
  test('maps platform data into a domain entity', () async {
    final repository = AudioCapabilitiesRepositoryImpl(
      dataSource: _FakeDataSource(),
    );

    final result = await repository.getCapabilities();

    expect(result, isA<Success<AudioCapabilities>>());
    expect(
      (result as Success<AudioCapabilities>).value.readiness,
      AudioReadiness.ready,
    );
  });
}

class _FakeDataSource implements AudioPlatformDataSource {
  @override
  Future<AudioCapabilitiesModel> getCapabilities() async {
    return const AudioCapabilitiesModel(
      platformVersion: 35,
      bluetoothAvailable: true,
      bluetoothPermissionGranted: true,
      bluetoothEnabled: true,
      leAudioSupported: true,
      broadcastSourceSupported: true,
    );
  }

  @override
  Future<void> openBluetoothSettings() async {}

  @override
  Future<bool> requestBluetoothPermissions() async => true;
}
