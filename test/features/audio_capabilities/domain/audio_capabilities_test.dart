import 'package:flutter_test/flutter_test.dart';
import 'package:onebeat/features/audio_capabilities/domain/entities/audio_capabilities.dart';

void main() {
  group('AudioCapabilities.readiness', () {
    test('is ready when Bluetooth and broadcast support are available', () {
      const capabilities = AudioCapabilities(
        platformVersion: 35,
        bluetoothAvailable: true,
        bluetoothPermissionGranted: true,
        bluetoothEnabled: true,
        leAudioSupported: true,
        broadcastSourceSupported: true,
      );

      expect(capabilities.readiness, AudioReadiness.ready);
    });

    test('requests Bluetooth when supported hardware is disabled', () {
      const capabilities = AudioCapabilities(
        platformVersion: 35,
        bluetoothAvailable: true,
        bluetoothPermissionGranted: true,
        bluetoothEnabled: false,
        leAudioSupported: true,
        broadcastSourceSupported: true,
      );

      expect(capabilities.readiness, AudioReadiness.bluetoothOff);
    });

    test('requests permission before evaluating protected capabilities', () {
      const capabilities = AudioCapabilities(
        platformVersion: 35,
        bluetoothAvailable: true,
        bluetoothPermissionGranted: false,
        bluetoothEnabled: false,
        leAudioSupported: false,
        broadcastSourceSupported: false,
      );

      expect(capabilities.readiness, AudioReadiness.permissionRequired);
    });

    test('is unsupported without broadcast-source support', () {
      const capabilities = AudioCapabilities(
        platformVersion: 33,
        bluetoothAvailable: true,
        bluetoothPermissionGranted: true,
        bluetoothEnabled: true,
        leAudioSupported: true,
        broadcastSourceSupported: false,
      );

      expect(capabilities.readiness, AudioReadiness.unsupported);
    });
  });
}
