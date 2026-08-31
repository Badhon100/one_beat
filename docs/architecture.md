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
