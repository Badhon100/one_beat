# Architecture decisions

## ADR-001: Android-first capability spike

**Status:** accepted

OneBeat targets Android first because Bluetooth LE Audio broadcast support can be
detected through Android platform APIs. iOS is deferred because general
third-party multi-A2DP routing is not available.

## ADR-002: Flutter owns product UI; Kotlin owns Android Bluetooth integration

**Status:** accepted

Dart communicates with Android through a narrow method-channel data source. No
Android type crosses the boundary. This keeps the domain portable and lets the
platform implementation evolve without coupling it to presentation code.

## ADR-003: No simulated multi-speaker connection

**Status:** accepted

The app reports actual platform capability. It does not expose a Connect button
until a supported, testable system or OEM broadcast flow has been selected.

## ADR-004: Separate playback engines for local files and YouTube

**Status:** accepted

Local files use `just_audio` behind a domain repository interface. YouTube
content uses the official YouTube IFrame player and is always presented as
visible audiovisual content. OneBeat never resolves or extracts YouTube media
URLs. Starting YouTube pauses the local engine so two sources cannot overlap.

## ADR-005: Local-first user library

**Status:** accepted

Tracks, favorites, categories, and playlists are serialized through a library
repository backed by SharedPreferences. The storage adapter can later be replaced
with SQLite without changing domain entities or presentation contracts.

## Layer rules

- `domain` imports only Dart and `core` code.
- `data` may import Flutter platform services and implements domain contracts.
- `presentation` depends on domain use cases, never concrete data sources.
- `app` is the only composition root.
- Android framework code stays under `android/`.

## Testing strategy

- Domain tests cover capability/readiness policy.
- Data tests cover mapping and error translation with fake sources.
- Controller tests cover loading and failure transitions.
- Widget tests cover visible states.
- Device tests will validate permissions and reported hardware capabilities.
