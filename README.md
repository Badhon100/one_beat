# OneBeat

OneBeat is an Android-first Flutter music player and Bluetooth LE Audio
capability app. It combines a personal local library, compliant YouTube embeds,
playlists, favorites, categories, and speaker-readiness checks in one experience.

> OneBeat does not claim to route audio to arbitrary Bluetooth Classic/A2DP
> speakers. Multi-device playback requires compatible LE Audio/Auracast phone
> hardware, receiver hardware, and operating-system support.

## Current functionality

- Imports multiple local audio files using the Android system picker.
- Plays local files with seek, queue, previous/next, shuffle, repeat-one,
  repeat-all, and audio-focus handling.
- Saves YouTube links and plays them through the official visible IFrame player.
- Persists user playlists, favorites, categories, and library metadata locally.
- Provides Home, Library, Playlists, Now Playing, YouTube Player, and Devices UI.
- Searches tracks and filters local, YouTube, and favorite content.
- Detects Android API level, Bluetooth state, LE Audio support, and broadcast
  source support through a native Kotlin platform channel.
- Requests Android 12+ nearby-device permissions.
- Opens system Bluetooth settings.
- Presents explicit ready, permission-required, Bluetooth-off, unsupported, and
  failure states.
- Unit tests Bluetooth readiness, YouTube URL parsing, persistence, and mapping.

## YouTube behavior

OneBeat does not download, extract, or isolate audio from YouTube. YouTube items
remain audiovisual and use the official embedded player with visible controls.
Background playback is intentionally unavailable for YouTube content. Some
videos cannot be embedded because of owner, region, age, or account restrictions.

## Enable YouTube browsing

OneBeat uses the official YouTube Data API for song search. Create a Google Cloud
project, enable **YouTube Data API v3**, and make an Android-restricted API key
for package `com.onebeat.app`. Keep the key out of Git, then run:

```shell
flutter run --dart-define=YOUTUBE_API_KEY=your_restricted_key
```

Without that setting, saved YouTube links still open in the visible embedded
player, but the Browse YouTube screen explains how to configure search.

## Architecture

The project follows feature-first Clean Architecture:

```text
lib/
├── app/                         # Composition root, app shell, theme
├── core/                        # Cross-feature result and failure types
└── features/
    ├── audio_capabilities/      # Android LE Audio capability feature
    ├── audio_player/            # Playback contract, just_audio adapter, player UI
    └── music_library/           # Tracks, playlists, persistence, library UI

android/app/src/main/kotlin/     # Android framework integration only
```

Dependencies point inward: presentation uses domain; data implements domain;
domain has no Flutter or Android imports. `AppDependencies` is the composition
root, keeping construction out of the feature UI.

## Run locally

Requirements: Flutter 3.41+ with an Android SDK and an Android device/emulator.

```shell
flutter pub get
flutter analyze
flutter test
flutter run
```

A physical Android 13+ phone is required for meaningful LE Audio capability
results. Emulator results are expected to report broadcast support as unavailable.

## Roadmap

1. Validate capability results on selected phone and Auracast speaker models.
2. Add paired-device observation and capability-specific onboarding.
3. Integrate the system/OEM audio-sharing flow available on supported phones.
4. Add local-audio notification and background playback controls.
5. Read embedded media metadata and local audio tags/artwork.
6. Measure end-to-end latency and synchronization on real hardware.
7. Decide whether a Wi-Fi receiver mode is needed for non-Auracast speakers.

The next phase must be based on tested target hardware because Android does not
offer a universal third-party API for routing one media stream to arbitrary
Bluetooth speakers.
