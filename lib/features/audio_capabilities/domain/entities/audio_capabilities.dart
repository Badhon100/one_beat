enum AudioReadiness { ready, permissionRequired, bluetoothOff, unsupported }

class AudioCapabilities {
  const AudioCapabilities({
    required this.platformVersion,
    required this.bluetoothAvailable,
    required this.bluetoothPermissionGranted,
    required this.bluetoothEnabled,
    required this.leAudioSupported,
    required this.broadcastSourceSupported,
  });

  final int platformVersion;
  final bool bluetoothAvailable;
  final bool bluetoothPermissionGranted;
  final bool bluetoothEnabled;
  final bool leAudioSupported;
  final bool broadcastSourceSupported;

  AudioReadiness get readiness {
    if (bluetoothAvailable && !bluetoothPermissionGranted) {
      return AudioReadiness.permissionRequired;
    }
    if (!bluetoothAvailable || !leAudioSupported || !broadcastSourceSupported) {
      return AudioReadiness.unsupported;
    }
    if (!bluetoothEnabled) return AudioReadiness.bluetoothOff;
    return AudioReadiness.ready;
  }
}
