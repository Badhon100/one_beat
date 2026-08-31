# OneBeat

OneBeat is an Android-first Flutter proof of concept for synchronized audio on
multiple Bluetooth LE Audio receivers. The current milestone detects whether a
phone exposes LE Audio broadcast-source capability and guides the user through
Bluetooth permission and settings.

> OneBeat does not claim to route audio to arbitrary Bluetooth Classic/A2DP
> speakers. Multi-device playback requires compatible LE Audio/Auracast phone
> hardware, receiver hardware, and operating-system support.

## Current functionality

- Detects Android API level, Bluetooth state, LE Audio support, and broadcast
  source support through a native Kotlin platform channel.
- Requests Android 12+ nearby-device permissions.
- Opens system Bluetooth settings.
- Presents explicit ready, permission-required, Bluetooth-off, unsupported, and
  failure states.
- Unit tests the domain readiness rules and data-to-domain mapping.

## Architecture

The project follows feature-first Clean Architecture:

```text
lib/
├── app/                         # Composition root, app shell, theme
├── core/                        # Cross-feature result and failure types
└── features/audio_capabilities/
    ├── presentation/            # Pages, widgets, controller
    ├── domain/                  # Entities, repository contract, use cases
    └── data/                    # Models, platform source, repository implementation

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
4. Add local media playback and background audio controls.
5. Measure end-to-end latency and synchronization on real hardware.
6. Decide whether a Wi-Fi receiver mode is needed for non-Auracast speakers.

The next phase must be based on tested target hardware because Android does not
offer a universal third-party API for routing one media stream to arbitrary
Bluetooth speakers.
