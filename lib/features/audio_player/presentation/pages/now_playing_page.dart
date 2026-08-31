import 'package:flutter/material.dart';

import '../../../music_library/presentation/controllers/music_controller.dart';
import '../../../music_library/presentation/widgets/track_artwork.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({required this.controller, super.key});
  final MusicController controller;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final track = controller.currentTrack;
    if (track == null) return const SizedBox.shrink();
    final max = controller.duration.inMilliseconds.toDouble();
    final value = controller.position.inMilliseconds
        .clamp(0, max <= 0 ? 0 : max)
        .toDouble();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4C2B72), Color(0xFF15121C), Color(0xFF0D0B12)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: TextStyle(fontSize: 11, letterSpacing: 1.8),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'OneBeat queue',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.queue_music_rounded),
                    ),
                  ],
                ),
                const Spacer(),
                Hero(
                  tag: 'now-playing-artwork',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 42,
                          offset: Offset(0, 22),
                        ),
                      ],
                    ),
                    child: TrackArtwork(
                      track: track,
                      size: MediaQuery.sizeOf(context).width.clamp(240, 340),
                      borderRadius: 30,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            track.artist,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .65),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.toggleFavorite(track),
                      icon: Icon(
                        track.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      color: track.isFavorite ? const Color(0xFFFF5C8A) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Slider(
                  value: value,
                  max: max <= 0 ? 1 : max,
                  onChanged: (next) =>
                      controller.seek(Duration(milliseconds: next.round())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(controller.position),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _format(controller.duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: controller.toggleShuffle,
                      color: controller.shuffleEnabled
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      icon: const Icon(Icons.shuffle_rounded),
                    ),
                    IconButton(
                      onPressed: controller.previous,
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 42,
                    ),
                    IconButton.filled(
                      onPressed: controller.togglePlayback,
                      icon: Icon(
                        controller.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      iconSize: 44,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.square(76),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.next,
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 42,
                    ),
                    IconButton(
                      onPressed: controller.cycleLoopMode,
                      color: controller.loopMode.name == 'off'
                          ? null
                          : Theme.of(context).colorScheme.primary,
                      icon: Icon(
                        controller.loopMode.name == 'one'
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
