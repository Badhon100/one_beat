import '../features/audio_capabilities/data/datasources/audio_platform_data_source.dart';
import '../features/audio_capabilities/data/repositories/audio_capabilities_repository_impl.dart';
import '../features/audio_capabilities/domain/usecases/get_audio_capabilities.dart';
import '../features/audio_capabilities/domain/usecases/open_bluetooth_settings.dart';
import '../features/audio_capabilities/domain/usecases/request_bluetooth_permissions.dart';
import '../features/audio_player/data/repositories/just_audio_playback_repository.dart';
import '../features/audio_player/domain/repositories/audio_playback_repository.dart';
import '../features/music_library/data/datasources/library_local_data_source.dart';
import '../features/music_library/data/datasources/local_audio_picker_data_source.dart';
import '../features/music_library/data/repositories/local_audio_repository_impl.dart';
import '../features/music_library/data/repositories/music_library_repository_impl.dart';
import '../features/music_library/domain/usecases/load_music_library.dart';
import '../features/music_library/domain/usecases/parse_youtube_url.dart';
import '../features/music_library/domain/usecases/pick_local_tracks.dart';
import '../features/music_library/domain/usecases/save_music_library.dart';
import '../features/music_library/presentation/controllers/music_controller.dart';
import '../features/youtube_search/data/repositories/youtube_search_repository_impl.dart';
import '../features/youtube_search/domain/usecases/search_youtube.dart';

class AppDependencies {
  const AppDependencies({
    required this.getAudioCapabilities,
    required this.openBluetoothSettings,
    required this.requestBluetoothPermissions,
    required this.loadMusicLibrary,
    required this.saveMusicLibrary,
    required this.pickLocalTracks,
    required this.audioPlayback,
    required this.searchYoutube,
  });

  factory AppDependencies.create() {
    const dataSource = MethodChannelAudioPlatformDataSource();
    const repository = AudioCapabilitiesRepositoryImpl(dataSource: dataSource);
    const libraryDataSource = SharedPreferencesLibraryDataSource();
    const libraryRepository = MusicLibraryRepositoryImpl(libraryDataSource);
    const pickerRepository = LocalAudioRepositoryImpl(
      FilePickerAudioDataSource(),
    );
    final youtubeRepository = YoutubeSearchRepositoryImpl(
      apiKey: const String.fromEnvironment('YOUTUBE_API_KEY'),
    );
    return AppDependencies(
      getAudioCapabilities: GetAudioCapabilities(repository),
      openBluetoothSettings: OpenBluetoothSettings(repository),
      requestBluetoothPermissions: RequestBluetoothPermissions(repository),
      loadMusicLibrary: const LoadMusicLibrary(libraryRepository),
      saveMusicLibrary: const SaveMusicLibrary(libraryRepository),
      pickLocalTracks: const PickLocalTracks(pickerRepository),
      audioPlayback: JustAudioPlaybackRepository(),
      searchYoutube: SearchYoutube(youtubeRepository),
    );
  }

  final GetAudioCapabilities getAudioCapabilities;
  final OpenBluetoothSettings openBluetoothSettings;
  final RequestBluetoothPermissions requestBluetoothPermissions;
  final LoadMusicLibrary loadMusicLibrary;
  final SaveMusicLibrary saveMusicLibrary;
  final PickLocalTracks pickLocalTracks;
  final AudioPlaybackRepository audioPlayback;
  final SearchYoutube searchYoutube;

  MusicController createMusicController() => MusicController(
    loadLibrary: loadMusicLibrary,
    saveLibrary: saveMusicLibrary,
    pickLocalTracks: pickLocalTracks,
    parseYoutubeUrl: const ParseYoutubeUrl(),
    playback: audioPlayback,
  );
}
