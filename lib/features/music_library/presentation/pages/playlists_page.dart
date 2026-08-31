import 'package:flutter/material.dart';

import '../../domain/entities/media_track.dart';
import '../../domain/entities/user_playlist.dart';
import '../controllers/music_controller.dart';
import '../widgets/track_tile.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({
    required this.controller,
    required this.onCreatePlaylist,
    required this.onTrackTap,
    required this.onTrackMore,
    super.key,
  });

  final MusicController controller;
  final VoidCallback onCreatePlaylist;
  final ValueChanged<MediaTrack> onTrackTap;
  final ValueChanged<MediaTrack> onTrackMore;

  @override
  Widget build(BuildContext context) {
    final playlists = controller.library.playlists;
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Playlists'),
          actions: [
            IconButton(
              onPressed: onCreatePlaylist,
              tooltip: 'New playlist',
              icon: const Icon(Icons.playlist_add_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        if (playlists.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.queue_music_rounded, size: 42),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Make your first playlist',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Group tracks for a mood, room, party, or anything else.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onCreatePlaylist,
                      icon: const Icon(Icons.add),
                      label: const Text('Create playlist'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .84,
              ),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _PlaylistCard(
                  playlist: playlist,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlaylistDetailPage(
                        playlist: playlist,
                        controller: controller,
                        onTrackTap: onTrackTap,
                        onTrackMore: onTrackMore,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onTap});
  final UserPlaylist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(playlist.colorValue),
                    Color(playlist.colorValue).withValues(alpha: .45),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.queue_music_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${playlist.trackIds.length} tracks',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage({
    required this.playlist,
    required this.controller,
    required this.onTrackTap,
    required this.onTrackMore,
    super.key,
  });

  final UserPlaylist playlist;
  final MusicController controller;
  final ValueChanged<MediaTrack> onTrackTap;
  final ValueChanged<MediaTrack> onTrackMore;

  @override
  Widget build(BuildContext context) {
    final current =
        controller.library.playlists
            .where((item) => item.id == playlist.id)
            .firstOrNull ??
        playlist;
    final tracks = current.trackIds
        .map(
          (id) => controller.library.tracks
              .where((track) => track.id == id)
              .firstOrNull,
        )
        .whereType<MediaTrack>()
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Center(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(current.colorValue),
                    Color(current.colorValue).withValues(alpha: .4),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.queue_music_rounded, size: 72),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            current.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (current.description.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(current.description, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          if (tracks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This playlist is empty. Use a track menu to add music.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...tracks.map(
              (track) => TrackTile(
                track: track,
                onTap: () => onTrackTap(track),
                onFavorite: () => controller.toggleFavorite(track),
                onMore: () => onTrackMore(track),
              ),
            ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
