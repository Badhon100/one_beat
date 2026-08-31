import 'package:flutter/material.dart';

import '../../domain/entities/media_track.dart';
import '../controllers/music_controller.dart';
import '../widgets/section_header.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';

class MusicHomePage extends StatelessWidget {
  const MusicHomePage({
    required this.controller,
    required this.onTrackTap,
    required this.onTrackMore,
    required this.onAddMusic,
    required this.onShowLibrary,
    super.key,
  });

  final MusicController controller;
  final ValueChanged<MediaTrack> onTrackTap;
  final ValueChanged<MediaTrack> onTrackMore;
  final VoidCallback onAddMusic;
  final VoidCallback onShowLibrary;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Row(
            children: [
              _Logo(),
              SizedBox(width: 10),
              Text('onebeat', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: onAddMusic,
              tooltip: 'Add music',
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          sliver: SliverList.list(
            children: [
              Text(
                'Your music, your space.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Local tracks, YouTube favorites, and speaker-ready sessions in one library.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _HeroCard(
                trackCount: controller.library.tracks.length,
                playlistCount: controller.library.playlists.length,
                onAdd: onAddMusic,
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Recently added',
                action: 'See all',
                onAction: onShowLibrary,
              ),
              const SizedBox(height: 12),
              if (controller.recentTracks.isEmpty)
                _EmptyLibrary(onAdd: onAddMusic)
              else
                SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentTracks.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final track = controller.recentTracks[index];
                      return _RecentCard(
                        track: track,
                        onTap: () => onTrackTap(track),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 26),
              if (controller.favoriteTracks.isNotEmpty) ...[
                const SectionHeader(title: 'Made for your favorites'),
                const SizedBox(height: 8),
                ...controller.favoriteTracks
                    .take(4)
                    .map(
                      (track) => TrackTile(
                        track: track,
                        isActive: controller.currentTrack?.id == track.id,
                        onTap: () => onTrackTap(track),
                        onFavorite: () => controller.toggleFavorite(track),
                        onMore: () => onTrackMore(track),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFFFB7185)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.multitrack_audio_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.trackCount,
    required this.playlistCount,
    required this.onAdd,
  });
  final int trackCount;
  final int playlistCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFBE185D), Color(0xFFEA580C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'YOUR ONEBEAT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '$trackCount tracks · $playlistCount playlists',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            'Build a library that moves with you.',
            style: TextStyle(color: Colors.white.withValues(alpha: .8)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF421A64),
              minimumSize: const Size(0, 46),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add music'),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.track, required this.onTap});
  final MediaTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrackArtwork(track: track, size: 145, borderRadius: 20),
            const SizedBox(height: 9),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.library_music_outlined, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Your library is waiting',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              'Import audio files or save a YouTube link.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your first track'),
            ),
          ],
        ),
      ),
    );
  }
}
