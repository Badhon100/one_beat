# OneBeat — Multi-Speaker Bluetooth Music Player

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter)](https://flutter.dev)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)

**OneBeat** is an open-source Flutter app exploring synchronized music playback
across multiple compatible Bluetooth speakers. Its core goal is to make it easy
to play one local music library through Bluetooth LE Audio and Auracast-capable
devices, while clearly showing whether the phone and speaker setup is ready.

Import and play your local MP3, M4A, WAV, and other device-supported audio
files; create playlists; manage favorites and categories; and check Bluetooth
LE Audio and Auracast readiness from one polished Android app.

> OneBeat is a local music player. It does not download, extract, or stream
> music from YouTube or other online sources.

## Download and get started

1. Open the latest [GitHub Release](https://github.com/Badhon100/one_beat/releases).
2. Download `onebeat-v1.0.0-debug.apk`.
3. Open the downloaded APK on an Android device and allow installation when Android asks.
4. Open OneBeat and choose **Add music** to import audio files from your device.

The debug APK is intended for testing. Android may show a warning for apps not
installed from Google Play; this is expected for a GitHub download.

## Primary goal: one song, multiple Bluetooth speakers

OneBeat focuses on multi-device audio sharing. On compatible Android hardware,
the intended flow is:

1. Import or select local music in OneBeat.
2. Check Bluetooth and LE Audio/Auracast readiness in **Devices**.
3. Use the phone's supported system or OEM audio-sharing flow to broadcast the
   active media session to multiple compatible receivers.
4. Keep playback controls, playlists, and the local library in OneBeat.

This focus guides the roadmap and community contributions.

## Current features

- Local Android audio player with multi-file import.
- Queue controls: play, pause, seek, next, previous, shuffle, repeat-one, and repeat-all.
- Background audio session and audio-focus handling.
- Personal playlists, favorites, categories, and local library persistence.
- Search across your local tracks, artists, and categories.
- Bluetooth capability screen for Android version, Bluetooth state, LE Audio,
  and Auracast broadcast-source readiness.
- Clear, Android-first Material UI built with Flutter.

## Important Bluetooth compatibility note

OneBeat can report whether a device appears ready for LE Audio/Auracast. It
does **not** claim to send one stream to arbitrary Bluetooth Classic/A2DP
speakers or bypass Android's audio-routing controls. True synchronized
multi-speaker playback requires compatible phone hardware, multiple LE
Audio/Auracast receivers, and operating-system or OEM support.

If your phone or speakers do not support LE Audio/Auracast broadcasting,
OneBeat still works as a local audio player, but synchronized multi-speaker
playback will not be available.

## Run from source

### Requirements

- Flutter 3.41 or newer
- Android SDK and an Android device or emulator
- Android 13+ physical hardware for meaningful Bluetooth LE Audio checks

```shell
git clone https://github.com/Badhon100/one_beat.git
cd one_beat
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build an APK

```shell
flutter build apk --debug
```

The output is at `build/app/outputs/flutter-apk/app-debug.apk`.

## Architecture

OneBeat follows feature-first Clean Architecture. Dependencies point inward:
presentation uses domain contracts, data implements them, and domain code has
no Flutter or Android imports.

```text
lib/
├── app/                         # Composition root, shell, theme
├── core/                        # Shared Result and failure types
└── features/
    ├── audio_capabilities/      # Android LE Audio capability feature
    ├── audio_player/            # Playback contract, adapter, player UI
    └── music_library/           # Tracks, playlists, persistence, library UI
```

See [docs/architecture.md](docs/architecture.md) for more detail.

## Contribute

Contributions are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md), then:

1. Fork the repository and create a focused branch.
2. Make your change with tests where applicable.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request describing the problem and the solution.

Good first contributions include LE Audio/Auracast device compatibility,
Bluetooth onboarding, local metadata/artwork, accessibility, and test coverage.
Please use the issue templates for bugs and feature requests.

## License

OneBeat is released under the [MIT License](LICENSE).
