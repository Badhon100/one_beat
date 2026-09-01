# Contributing to OneBeat

Thanks for helping improve OneBeat. This project welcomes bug reports,
documentation improvements, design feedback, tests, and code contributions.

## Before you start

- Search existing issues and pull requests to avoid duplicates.
- For larger features or behavior changes, open an issue first so the approach
  can be discussed.
- Keep each pull request focused on one improvement.

## Development workflow

```shell
git clone https://github.com/Badhon100/one_beat.git
cd one_beat
flutter pub get
flutter analyze
flutter test
```

Create a branch with a clear name, such as `fix/library-search` or
`feat/local-artwork`, then open a pull request against `main`.

## Code expectations

- Preserve the feature-first Clean Architecture boundaries.
- Keep domain code independent of Flutter and Android framework APIs.
- Prefer clear names and small, testable units.
- Format changed Dart code with `dart format`.
- Add or update tests when behavior changes.
- Run `flutter analyze` and `flutter test` before opening a pull request.

## Pull requests

In the pull-request description, explain:

1. What problem the change solves.
2. How you tested it.
3. Any Android versions, devices, or permissions affected.

By contributing, you agree that your contributions may be distributed under the
project's [MIT License](LICENSE).
