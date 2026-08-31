import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/audio_capabilities.dart';
import '../../domain/usecases/get_audio_capabilities.dart';
import '../../domain/usecases/open_bluetooth_settings.dart';
import '../../domain/usecases/request_bluetooth_permissions.dart';

enum CapabilitiesViewStatus { initial, loading, loaded, failure }

class AudioCapabilitiesController extends ChangeNotifier {
  AudioCapabilitiesController({
    required GetAudioCapabilities getAudioCapabilities,
    required OpenBluetoothSettings openBluetoothSettings,
    required RequestBluetoothPermissions requestBluetoothPermissions,
  }) : _getAudioCapabilities = getAudioCapabilities,
       _openBluetoothSettings = openBluetoothSettings,
       _requestBluetoothPermissions = requestBluetoothPermissions;

  final GetAudioCapabilities _getAudioCapabilities;
  final OpenBluetoothSettings _openBluetoothSettings;
  final RequestBluetoothPermissions _requestBluetoothPermissions;

  CapabilitiesViewStatus status = CapabilitiesViewStatus.initial;
  AudioCapabilities? capabilities;
  String? errorMessage;

  Future<void> load() async {
    status = CapabilitiesViewStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _getAudioCapabilities();
    switch (result) {
      case Success(value: final value):
        capabilities = value;
        status = CapabilitiesViewStatus.loaded;
      case Failure(failure: final failure):
        errorMessage = failure.message;
        status = CapabilitiesViewStatus.failure;
    }
    notifyListeners();
  }

  Future<String?> openSettings() async {
    final result = await _openBluetoothSettings();
    return switch (result) {
      Success() => null,
      Failure(failure: final failure) => failure.message,
    };
  }

  Future<String?> requestPermission() async {
    final result = await _requestBluetoothPermissions();
    switch (result) {
      case Success():
        await load();
        return null;
      case Failure(failure: final failure):
        return failure.message;
    }
  }
}
