import 'package:flutter/material.dart';

import '../../../music_library/presentation/controllers/music_controller.dart';
import '../../../music_library/presentation/widgets/track_artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({required this.controller, required this.onOpen, super.key});

  final MusicController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final track = controller.currentTrack;
    if (track == null) return const SizedBox.shrink();
    final max = controller.duration.inMilliseconds.toDouble();
    final progress = max == 0
        ? 0.0
        : controller.position.inMilliseconds.clamp(0, max.toInt()).toDouble() /
              max;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  TrackArtwork(track: track, size: 44, borderRadius: 12),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.togglePlayback,
                    icon: Icon(
                      controller.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 36,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.next,
                    icon: const Icon(Icons.skip_next_rounded),
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
