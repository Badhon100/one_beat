import '../../domain/entities/audio_capabilities.dart';

class AudioCapabilitiesModel {
  const AudioCapabilitiesModel({
    required this.platformVersion,
    required this.bluetoothAvailable,
    required this.bluetoothPermissionGranted,
    required this.bluetoothEnabled,
    required this.leAudioSupported,
    required this.broadcastSourceSupported,
  });

  factory AudioCapabilitiesModel.fromMap(Map<Object?, Object?> map) {
    return AudioCapabilitiesModel(
      platformVersion: map['platformVersion'] as int? ?? 0,
      bluetoothAvailable: map['bluetoothAvailable'] as bool? ?? false,
      bluetoothPermissionGranted:
          map['bluetoothPermissionGranted'] as bool? ?? false,
      bluetoothEnabled: map['bluetoothEnabled'] as bool? ?? false,
      leAudioSupported: map['leAudioSupported'] as bool? ?? false,
      broadcastSourceSupported:
          map['broadcastSourceSupported'] as bool? ?? false,
    );
  }

  final int platformVersion;
  final bool bluetoothAvailable;
  final bool bluetoothPermissionGranted;
  final bool bluetoothEnabled;
  final bool leAudioSupported;
  final bool broadcastSourceSupported;

  AudioCapabilities toEntity() => AudioCapabilities(
    platformVersion: platformVersion,
    bluetoothAvailable: bluetoothAvailable,
    bluetoothPermissionGranted: bluetoothPermissionGranted,
    bluetoothEnabled: bluetoothEnabled,
    leAudioSupported: leAudioSupported,
    broadcastSourceSupported: broadcastSourceSupported,
  );
}
