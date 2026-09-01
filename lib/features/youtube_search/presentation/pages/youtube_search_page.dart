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
    } else {
      _controller.message =
          'To enable in-app song browsing, run OneBeat with a restricted YouTube Data API key using --dart-define=YOUTUBE_API_KEY=your_key.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse YouTube Audio')),
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
          if (_controller.isSearching)
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
