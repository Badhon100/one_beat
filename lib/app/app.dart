import 'package:flutter/material.dart';

import '../features/audio_capabilities/presentation/controllers/audio_capabilities_controller.dart';
import '../features/audio_capabilities/presentation/pages/audio_capabilities_page.dart';
import '../features/music_library/presentation/controllers/music_controller.dart';
import 'dependencies.dart';
import 'music_shell_page.dart';
import 'theme/onebeat_theme.dart';

class OneBeatApp extends StatefulWidget {
  const OneBeatApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<OneBeatApp> createState() => _OneBeatAppState();
}

class _OneBeatAppState extends State<OneBeatApp> {
  late final MusicController _musicController;
  late final AudioCapabilitiesController _audioCapabilitiesController;

  @override
  void initState() {
    super.initState();
    _musicController = widget.dependencies.createMusicController();
    _audioCapabilitiesController = AudioCapabilitiesController(
      getAudioCapabilities: widget.dependencies.getAudioCapabilities,
      openBluetoothSettings: widget.dependencies.openBluetoothSettings,
      requestBluetoothPermissions:
          widget.dependencies.requestBluetoothPermissions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneBeat',
      debugShowCheckedModeBanner: false,
      theme: OneBeatTheme.dark,
      themeMode: ThemeMode.dark,
      home: MusicShellPage(
        controller: _musicController,
        devicesPage: AudioCapabilitiesPage(
          controller: _audioCapabilitiesController,
        ),
      ),
    );
  }
}
