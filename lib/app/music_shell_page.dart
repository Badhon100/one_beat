import 'package:flutter/material.dart';

import '../features/audio_player/presentation/pages/now_playing_page.dart';
import '../features/audio_player/presentation/pages/youtube_player_page.dart';
import '../features/audio_player/presentation/widgets/mini_player.dart';
import '../features/music_library/domain/entities/media_track.dart';
import '../features/music_library/domain/entities/user_playlist.dart';
import '../features/music_library/presentation/controllers/music_controller.dart';
import '../features/music_library/presentation/pages/library_page.dart';
import '../features/music_library/presentation/pages/music_home_page.dart';
import '../features/music_library/presentation/pages/playlists_page.dart';

class MusicShellPage extends StatefulWidget {
  const MusicShellPage({
    required this.controller,
    required this.devicesPage,
    super.key,
  });

  final MusicController controller;
  final Widget devicesPage;

  @override
  State<MusicShellPage> createState() => _MusicShellPageState();
}

class _MusicShellPageState extends State<MusicShellPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    widget.controller
      ..addListener(_refresh)
      ..initialize();
  }

  @override
  void dispose() {
    widget.controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final pages = [
      MusicHomePage(
        controller: widget.controller,
        onTrackTap: _openTrack,
        onTrackMore: _showTrackActions,
        onAddMusic: _showAddMusic,
        onShowLibrary: () => setState(() => _index = 1),
      ),
      LibraryPage(
        controller: widget.controller,
        onTrackTap: _openTrack,
        onTrackMore: _showTrackActions,
        onAddMusic: _showAddMusic,
      ),
      PlaylistsPage(
        controller: widget.controller,
        onCreatePlaylist: _showCreatePlaylist,
        onTrackTap: _openTrack,
        onTrackMore: _showTrackActions,
      ),
      widget.devicesPage,
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            controller: widget.controller,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NowPlayingPage(controller: widget.controller),
              ),
            ),
          ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_music_outlined),
                selectedIcon: Icon(Icons.queue_music_rounded),
                label: 'Playlists',
              ),
              NavigationDestination(
                icon: Icon(Icons.speaker_group_outlined),
                selectedIcon: Icon(Icons.speaker_group_rounded),
                label: 'Devices',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openTrack(MediaTrack track) async {
    if (track.isLocal) {
      final message = await widget.controller.playLocalTrack(track);
      if (message != null) _showMessage(message);
      return;
    }
    await widget.controller.pause();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => YoutubePlayerPage(track: track)),
    );
  }

  Future<void> _showAddMusic() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to OneBeat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _SourceOption(
                icon: Icons.audio_file_rounded,
                color: const Color(0xFF8B5CF6),
                title: 'Import local audio',
                subtitle: 'Choose one or more audio files from this device',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _importLocal();
                },
              ),
              const SizedBox(height: 10),
              _SourceOption(
                icon: Icons.smart_display_rounded,
                color: const Color(0xFFEF4444),
                title: 'Add YouTube link',
                subtitle: 'Save and play through the official YouTube player',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showYoutubeForm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importLocal() async {
    final message = await widget.controller.importLocalTracks();
    if (message != null) _showMessage(message);
  }

  Future<void> _showYoutubeForm() async {
    final url = TextEditingController();
    final title = TextEditingController();
    final artist = TextEditingController();
    final category = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add from YouTube',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('OneBeat uses YouTube\'s official visible player.'),
              const SizedBox(height: 18),
              TextField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'YouTube link',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artist,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Artist or channel',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: category,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Focus, Party, Podcast…',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  final message = await widget.controller.addYoutubeTrack(
                    url: url.text,
                    title: title.text,
                    artist: artist.text,
                    category: category.text,
                  );
                  if (message == null && sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                  if (message != null) _showMessage(message);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add to library'),
              ),
            ],
          ),
        ),
      ),
    );
    url.dispose();
    title.dispose();
    artist.dispose();
    category.dispose();
  }

  Future<void> _showCreatePlaylist() async {
    final name = TextEditingController();
    final description = TextEditingController();
    var color = 0xFF7C3AED;
    const colors = [0xFF7C3AED, 0xFFDB2777, 0xFFEA580C, 0xFF0891B2, 0xFF16A34A];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Playlist name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colors
                    .map(
                      (value) => InkWell(
                        onTap: () => setDialogState(() => color = value),
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(value),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color == value
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final message = await widget.controller.createPlaylist(
                  name: name.text,
                  description: description.text,
                  colorValue: color,
                );
                if (message == null && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (message != null) _showMessage(message);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    description.dispose();
  }

  Future<void> _showTrackActions(MediaTrack track) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  track.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                title: Text(
                  track.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.controller.toggleFavorite(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('Add to playlist'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _choosePlaylist(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Change category'),
                subtitle: Text(track.category),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _changeCategory(track);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text('Remove from library'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.controller.removeTrack(track);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choosePlaylist(MediaTrack track) async {
    final playlists = widget.controller.library.playlists;
    if (playlists.isEmpty) {
      _showMessage('Create a playlist first.');
      return;
    }
    final selected = await showDialog<UserPlaylist>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Add to playlist'),
        children: playlists
            .map(
              (playlist) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, playlist),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Color(playlist.colorValue),
                    child: const Icon(Icons.music_note_rounded),
                  ),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.trackIds.length} tracks'),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      final message = await widget.controller.addTrackToPlaylist(
        track,
        selected,
      );
      if (message != null) _showMessage(message);
    }
  }

  Future<void> _changeCategory(MediaTrack track) async {
    final input = TextEditingController(text: track.category);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change category'),
        content: TextField(
          controller: input,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, input.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    input.dispose();
    if (value != null) {
      final message = await widget.controller.updateCategory(track, value);
      if (message != null) _showMessage(message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .18),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
