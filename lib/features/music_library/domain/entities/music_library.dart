import 'media_track.dart';
import 'user_playlist.dart';

class MusicLibrary {
  const MusicLibrary({this.tracks = const [], this.playlists = const []});

  final List<MediaTrack> tracks;
  final List<UserPlaylist> playlists;

  MusicLibrary copyWith({
    List<MediaTrack>? tracks,
    List<UserPlaylist>? playlists,
  }) {
    return MusicLibrary(
      tracks: tracks ?? this.tracks,
      playlists: playlists ?? this.playlists,
    );
  }
}
