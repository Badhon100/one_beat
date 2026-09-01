import 'package:flutter/services.dart';

import '../models/audio_capabilities_model.dart';

abstract interface class AudioPlatformDataSource {
  Future<AudioCapabilitiesModel> getCapabilities();
  Future<bool> requestBluetoothPermissions();
  Future<void> openBluetoothSettings();
}

class MethodChannelAudioPlatformDataSource implements AudioPlatformDataSource {
  const MethodChannelAudioPlatformDataSource();

  static const _channel = MethodChannel(
    'com.badhon.one_beat/audio_capabilities',
  );

  @override
  Future<AudioCapabilitiesModel> getCapabilities() async {
    final response = await _channel.invokeMethod<Map<Object?, Object?>>(
      'getCapabilities',
    );
    if (response == null) {
      throw const FormatException('The platform returned no capability data.');
    }
    return AudioCapabilitiesModel.fromMap(response);
  }

  @override
  Future<void> openBluetoothSettings() {
    return _channel.invokeMethod<void>('openBluetoothSettings');
  }

  @override
  Future<bool> requestBluetoothPermissions() async {
    return await _channel.invokeMethod<bool>('requestBluetoothPermissions') ??
        false;
  }
}
