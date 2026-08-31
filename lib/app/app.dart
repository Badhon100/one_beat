import 'package:flutter/material.dart';

import '../features/audio_capabilities/presentation/controllers/audio_capabilities_controller.dart';
import '../features/audio_capabilities/presentation/pages/audio_capabilities_page.dart';
import 'dependencies.dart';
import 'theme/onebeat_theme.dart';

class OneBeatApp extends StatelessWidget {
  const OneBeatApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneBeat',
      debugShowCheckedModeBanner: false,
      theme: OneBeatTheme.light,
      home: AudioCapabilitiesPage(
        controller: AudioCapabilitiesController(
          getAudioCapabilities: dependencies.getAudioCapabilities,
          openBluetoothSettings: dependencies.openBluetoothSettings,
          requestBluetoothPermissions: dependencies.requestBluetoothPermissions,
        ),
      ),
    );
  }
}
