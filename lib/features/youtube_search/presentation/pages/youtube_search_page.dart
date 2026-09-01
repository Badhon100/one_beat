import 'package:flutter/material.dart';

import '../../../../app/dependencies.dart';
import '../../../music_library/domain/entities/media_track.dart';
import '../../../music_library/presentation/controllers/music_controller.dart';
import '../controllers/youtube_search_controller.dart';

class YoutubeSearchPage extends StatefulWidget {
  const YoutubeSearchPage({
    required this.dependencies,
    required this.controller,
    required this.onTrackAdded,
    required this.onTrackSelected,
    super.key,
  });

  final AppDependencies dependencies;
  final MusicController controller;
  final ValueChanged<MediaTrack> onTrackAdded;
  final ValueChanged<MediaTrack> onTrackSelected;

  @override
  State<YoutubeSearchPage> createState() => _YoutubeSearchPageState();
}

class _YoutubeSearchPageState extends State<YoutubeSearchPage> {
  late final YoutubeSearchController _controller;
  final _searchQuery = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = YoutubeSearchController(widget.dependencies.searchYoutube)
      ..addListener(_refresh);
    if (_controller.isConfigured) {
      _controller.search('trending music');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<MediaTrack> get _savedYoutubeTracks => widget.controller.library.tracks
      .where((track) => track.sourceType == MediaSourceType.youtube)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse YouTube')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchQuery,
              enabled: _controller.isConfigured,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, channels...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_controller.isConfigured) {
                      _controller.search(_searchQuery.text);
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
              onSubmitted: (value) => _controller.search(value),
            ),
          ),
          if (!_controller.isConfigured)
            Expanded(
              child: _SavedYoutubeList(
                tracks: _savedYoutubeTracks,
                onTrackSelected: widget.onTrackSelected,
              ),
            )
          else if (_controller.isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_controller.message != null && _controller.results.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    _controller.message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _controller.results.length,
                itemBuilder: (context, index) {
                  final result = _controller.results[index];
                  final track = MediaTrack(
                    id: 'youtube_${DateTime.now().microsecondsSinceEpoch}_$index',
                    title: result.title,
                    artist: result.channelTitle,
                    location: result.watchUrl,
                    sourceType: MediaSourceType.youtube,
                    youtubeVideoId: result.videoId,
                    addedAt: DateTime.now(),
                  );

                  return ListTile(
                    onTap: () => widget.onTrackSelected(track),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        result.thumbnailUrl,
                        width: 60,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 45,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note_rounded),
                        ),
                      ),
                    ),
                    title: Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(result.channelTitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () {
                        widget.onTrackAdded(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${result.title}" added to library.',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SavedYoutubeList extends StatelessWidget {
  const _SavedYoutubeList({
    required this.tracks,
    required this.onTrackSelected,
  });

  final List<MediaTrack> tracks;
  final ValueChanged<MediaTrack> onTrackSelected;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your saved YouTube tracks will appear here. Add a YouTube link from the music menu to build your list.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: tracks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Text(
              'Saved YouTube music',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          );
        }
        final track = tracks[index - 1];
        return ListTile(
          onTap: () => onTrackSelected(track),
          leading: const CircleAvatar(child: Icon(Icons.play_arrow_rounded)),
          title: Text(
            track.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        );
      },
    );
  }
}
