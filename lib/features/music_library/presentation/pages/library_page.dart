import 'package:flutter/material.dart';

import '../../domain/entities/media_track.dart';
import '../controllers/music_controller.dart';
import '../widgets/track_tile.dart';

enum _TrackFilter { all, favorites }

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    required this.controller,
    required this.onTrackTap,
    required this.onTrackMore,
    required this.onAddMusic,
    super.key,
  });

  final MusicController controller;
  final ValueChanged<MediaTrack> onTrackTap;
  final ValueChanged<MediaTrack> onTrackMore;
  final VoidCallback onAddMusic;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _searchController = TextEditingController();
  _TrackFilter _filter = _TrackFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final tracks = widget.controller.library.tracks
        .where((track) {
          final matchesQuery =
              query.isEmpty ||
              track.title.toLowerCase().contains(query) ||
              track.artist.toLowerCase().contains(query) ||
              track.category.toLowerCase().contains(query);
          final matchesFilter = switch (_filter) {
            _TrackFilter.all => true,
            _TrackFilter.favorites => track.isFavorite,
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Your library'),
          actions: [
            IconButton(
              onPressed: widget.onAddMusic,
              tooltip: 'Add music',
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search tracks, artists, or categories',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _TrackFilter.values
                        .map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                              label: Text(switch (filter) {
                                _TrackFilter.all => 'All',
                                _TrackFilter.favorites => 'Favorites',
                              }),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tracks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 52),
                    const SizedBox(height: 14),
                    Text(
                      widget.controller.library.tracks.isEmpty
                          ? 'No music yet'
                          : 'No matching tracks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.controller.library.tracks.isEmpty
                          ? 'Import audio files from this device to begin.'
                          : 'Try another search or filter.',
                      textAlign: TextAlign.center,
                    ),
                    if (widget.controller.library.tracks.isEmpty) ...[
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: widget.onAddMusic,
                        icon: const Icon(Icons.add),
                        label: const Text('Add music'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: SliverList.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return TrackTile(
                  track: track,
                  isActive: widget.controller.currentTrack?.id == track.id,
                  onTap: () => widget.onTrackTap(track),
                  onFavorite: () => widget.controller.toggleFavorite(track),
                  onMore: () => widget.onTrackMore(track),
                );
              },
            ),
          ),
      ],
    );
  }
}
