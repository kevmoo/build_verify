## 3.1.0

- `expectBuildClean`: add `gitDiffPathArguments` parameter.
- Use `--relative` in `git diff` command instead of just `.`.
- Require Dart >= 2.18.0

## 3.0.1

- Run `git diff` only on the current working directory.
- Require Dart >= 2.17.0

## 3.0.0

- `expectBuildClean` is now async. (Returns `Future<void>` instead of `void`.)
- `defaultCommand` now uses `dart run build_runner...`.
- Now supports `flutter test`.
- Executed commands are now printed to the console.
- Require Dart `2.12.3`.

## 2.0.0

- Require Dart `2.12.0`.
- Enable null safety.

## 1.1.1

- Properly report good builds that take >= 1 minute.

## 1.1.0

- Added `customCommand` named argument to `expectBuildClean`.

## 1.0.0

- Initial version, created by Stagehand.
