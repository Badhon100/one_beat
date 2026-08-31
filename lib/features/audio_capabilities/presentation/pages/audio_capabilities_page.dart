import 'package:flutter/material.dart';

import '../../domain/entities/audio_capabilities.dart';
import '../controllers/audio_capabilities_controller.dart';
import '../widgets/capability_tile.dart';
import '../widgets/onebeat_mark.dart';

class AudioCapabilitiesPage extends StatefulWidget {
  const AudioCapabilitiesPage({required this.controller, super.key});

  final AudioCapabilitiesController controller;

  @override
  State<AudioCapabilitiesPage> createState() => _AudioCapabilitiesPageState();
}

class _AudioCapabilitiesPageState extends State<AudioCapabilitiesPage> {
  @override
  void initState() {
    super.initState();
    widget.controller
      ..addListener(_refresh)
      ..load();
  }

  @override
  void dispose() {
    widget.controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              const OneBeatMark(),
              const SizedBox(height: 36),
              Text(
                'One song. Every speaker.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'First, let\'s check whether this phone can broadcast synchronized LE Audio.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final controller = widget.controller;
    if (controller.status == CapabilitiesViewStatus.initial ||
        controller.status == CapabilitiesViewStatus.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.status == CapabilitiesViewStatus.failure) {
      return _MessageCard(
        message: controller.errorMessage ?? 'Something unexpected happened.',
        onRetry: controller.load,
      );
    }

    final capabilities = controller.capabilities!;
    return Column(
      children: [
        _ReadinessCard(capabilities: capabilities),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CapabilityTile(
                  label: 'Permission',
                  value: capabilities.bluetoothPermissionGranted
                      ? 'Allowed'
                      : 'Required',
                  supported: capabilities.bluetoothPermissionGranted,
                ),
                const Divider(height: 28),
                CapabilityTile(
                  label: 'Bluetooth',
                  value: capabilities.bluetoothEnabled ? 'On' : 'Off',
                  supported: capabilities.bluetoothEnabled,
                ),
                const Divider(height: 28),
                CapabilityTile(
                  label: 'LE Audio',
                  value: capabilities.leAudioSupported
                      ? 'Supported'
                      : 'Unavailable',
                  supported: capabilities.leAudioSupported,
                ),
                const Divider(height: 28),
                CapabilityTile(
                  label: 'Broadcast source',
                  value: capabilities.broadcastSourceSupported
                      ? 'Supported'
                      : 'Unavailable',
                  supported: capabilities.broadcastSourceSupported,
                ),
                const Divider(height: 28),
                CapabilityTile(
                  label: 'Android API',
                  value: '${capabilities.platformVersion}',
                  supported: capabilities.platformVersion >= 33,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: capabilities.bluetoothPermissionGranted
              ? _openSettings
              : _requestPermission,
          icon: const Icon(Icons.bluetooth_rounded),
          label: Text(
            capabilities.bluetoothPermissionGranted
                ? 'Open Bluetooth settings'
                : 'Allow Bluetooth access',
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Check again'),
        ),
      ],
    );
  }

  Future<void> _openSettings() async {
    final message = await widget.controller.openSettings();
    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _requestPermission() async {
    final message = await widget.controller.requestPermission();
    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.capabilities});
  final AudioCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final (icon, title, message, color) = switch (capabilities.readiness) {
      AudioReadiness.ready => (
        Icons.graphic_eq_rounded,
        'Ready for the next step',
        'This phone reports LE Audio broadcast-source support.',
        const Color(0xFF0F9D76),
      ),
      AudioReadiness.bluetoothOff => (
        Icons.bluetooth_disabled_rounded,
        'Turn on Bluetooth',
        'The required hardware is available, but Bluetooth is currently off.',
        const Color(0xFFF59E0B),
      ),
      AudioReadiness.permissionRequired => (
        Icons.lock_outline_rounded,
        'Bluetooth access needed',
        'Allow nearby-device access so OneBeat can check compatible audio hardware.',
        const Color(0xFFF59E0B),
      ),
      AudioReadiness.unsupported => (
        Icons.info_outline_rounded,
        'Broadcasting is unavailable',
        'OneBeat needs Android 13+ and phone hardware with LE Audio broadcast support.',
        const Color(0xFF6D5DFB),
      ),
    };

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Capability check failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
