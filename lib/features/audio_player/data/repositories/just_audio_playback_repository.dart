import 'dart:async';
import 'dart:developer' as dev;
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../music_library/domain/entities/media_track.dart';
import '../../domain/entities/player_loop_mode.dart';
import '../../domain/repositories/audio_playback_repository.dart';

/// Dual-player playback repository:
/// - Local files → just_audio (AudioPlayer)
/// - YouTube tracks → youtube_player_iframe (YoutubePlayerController)
class JustAudioPlaybackRepository implements AudioPlaybackRepository {
  JustAudioPlaybackRepository() : _localPlayer = AudioPlayer();

  final AudioPlayer _localPlayer;
  yt.YoutubePlayerController? _ytPlayer;
  bool _sessionConfigured = false;

  // ── Active player tracking ──
  bool _isYouTubeActive = false;
  List<MediaTrack> _currentQueue = [];
  int _currentIndex = 0;

  // ── Stream controllers for unified interface ──
  final _playingController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _indexController = StreamController<int?>.broadcast();
  final _shuffleController = StreamController<bool>.broadcast();
  final _loopModeController = StreamController<PlayerLoopMode>.broadcast();

  Timer? _ytPositionTimer;
  final List<StreamSubscription<Object?>> _localSubs = [];

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<int?> get currentIndexStream => _indexController.stream;

  @override
  Stream<bool> get shuffleStream => _shuffleController.stream;

  @override
  Stream<PlayerLoopMode> get loopModeStream => _loopModeController.stream;

  @override
  Future<Result<void>> setQueue(
    List<MediaTrack> tracks,
    int initialIndex,
  ) async {
    try {
      await _configureSession();
      _currentQueue = List.unmodifiable(tracks);
      _currentIndex = initialIndex;

      final track = tracks[initialIndex];
      await _playTrack(track);

      _indexController.add(_currentIndex);
      return const Success(null);
    } on Object catch (error) {
      dev.log('Audio playback error', error: error);
      return Failure(
        AppFailure('This audio file could not be played.', cause: error),
      );
    }
  }

  Future<void> _playTrack(MediaTrack track) async {
    // Stop whichever player is active
    await _stopAll();

    if (track.isLocal) {
      _isYouTubeActive = false;
      _listenToLocalPlayer();

      final mediaItem = MediaItem(
        id: track.id,
        album: track.category,
        title: track.title,
        artist: track.artist,
      );
      await _localPlayer.setAudioSource(
        AudioSource.file(track.location, tag: mediaItem),
      );
    } else {
      _isYouTubeActive = true;
      final videoId = track.youtubeVideoId;
      if (videoId == null || videoId.isEmpty) {
        throw const AppFailure('Missing YouTube video ID.');
      }

      _ytPlayer?.close();
      _ytPlayer = yt.YoutubePlayerController(
        params: const yt.YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          mute: false,
          enableCaption: false,
          playsInline: true,
        ),
      );

      // Load the video
      await _ytPlayer!.loadVideoById(videoId: videoId);

      // Listen to YouTube player state
      _startYouTubeListeners();
    }
  }

  void _listenToLocalPlayer() {
    _cancelLocalSubs();
    _localSubs.addAll([
      _localPlayer.playingStream.listen((v) => _playingController.add(v)),
      _localPlayer.positionStream.listen((v) => _positionController.add(v)),
      _localPlayer.durationStream.listen((v) => _durationController.add(v)),
      _localPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onTrackCompleted();
        }
      }),
    ]);
  }

  void _startYouTubeListeners() {
    _cancelYouTubeSubs();

    _ytPlayer?.listen((event) {
      switch (event.playerState) {
        case yt.PlayerState.playing:
          _playingController.add(true);
        case yt.PlayerState.paused:
        case yt.PlayerState.buffering:
        case yt.PlayerState.cued:
          _playingController.add(false);
        case yt.PlayerState.ended:
          _playingController.add(false);
          _onTrackCompleted();
        default:
          break;
      }
    });

    // Poll position/duration for YouTube player
    _ytPositionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) async {
        if (_ytPlayer == null) return;
        try {
          final pos = await _ytPlayer!.currentTime;
          final dur = await _ytPlayer!.duration;
          _positionController.add(Duration(seconds: pos.toInt()));
          _durationController.add(Duration(seconds: dur.toInt()));
        } catch (_) {}
      },
    );
  }

  Future<void> _onTrackCompleted() async {
    if (_currentIndex < _currentQueue.length - 1) {
      _currentIndex++;
      _indexController.add(_currentIndex);
      await _playTrack(_currentQueue[_currentIndex]);
      await play();
    } else {
      _playingController.add(false);
    }
  }

  Future<void> _stopAll() async {
    _cancelLocalSubs();
    _cancelYouTubeSubs();
    try {
      await _localPlayer.stop();
    } catch (_) {}
    try {
      _ytPlayer?.close();
      _ytPlayer = null;
    } catch (_) {}
  }

  void _cancelLocalSubs() {
    for (final sub in _localSubs) {
      sub.cancel();
    }
    _localSubs.clear();
  }

  void _cancelYouTubeSubs() {
    _ytPositionTimer?.cancel();
    _ytPositionTimer = null;
  }

  Future<void> _configureSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;
  }

  @override
  Future<void> play() async {
    if (_isYouTubeActive) {
      await _ytPlayer?.playVideo();
    } else {
      await _localPlayer.play();
    }
  }

  @override
  Future<void> pause() async {
    if (_isYouTubeActive) {
      await _ytPlayer?.pauseVideo();
    } else {
      await _localPlayer.pause();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isYouTubeActive) {
      await _ytPlayer?.seekTo(seconds: position.inSeconds.toDouble());
    } else {
      await _localPlayer.seek(position);
    }
  }

  @override
  Future<void> next() async {
    if (_currentIndex < _currentQueue.length - 1) {
      _currentIndex++;
      _indexController.add(_currentIndex);
      await _playTrack(_currentQueue[_currentIndex]);
      await play();
    }
  }

  @override
  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _indexController.add(_currentIndex);
      await _playTrack(_currentQueue[_currentIndex]);
      await play();
    }
  }

  @override
  Future<void> setShuffle(bool enabled) async {
    if (!_isYouTubeActive) {
      await _localPlayer.setShuffleModeEnabled(enabled);
    }
    _shuffleController.add(enabled);
  }

  @override
  Future<void> setLoopMode(PlayerLoopMode mode) async {
    if (!_isYouTubeActive) {
      await _localPlayer.setLoopMode(switch (mode) {
        PlayerLoopMode.off => LoopMode.off,
        PlayerLoopMode.one => LoopMode.one,
        PlayerLoopMode.all => LoopMode.all,
      });
    }
    _loopModeController.add(mode);
  }

  @override
  Future<void> dispose() async {
    await _stopAll();
    await _localPlayer.dispose();
    _playingController.close();
    _positionController.close();
    _durationController.close();
    _indexController.close();
    _shuffleController.close();
    _loopModeController.close();
  }

  /// Exposes the YouTube player controller so a widget can embed the
  /// player view (hidden or visible) in the widget tree.
  yt.YoutubePlayerController? get youtubePlayerController => _ytPlayer;

  /// Whether the active player is the YouTube iframe player.
  bool get isYouTubeActive => _isYouTubeActive;
}
