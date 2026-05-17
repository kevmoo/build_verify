import 'dart:io';

import 'src/impl.dart';

/// The default value for `customCommand` in [expectBuildClean].
const defaultCommand = [
  dartPlaceHolder,
  'run',
  'build_runner',
  'build',
  '--delete-conflicting-outputs',
];

/// If [customCommand] is not specified, [defaultCommand] is used.
///
/// The first item in [customCommand] is used as the executable to run. The
/// remaining values are used as the executable arguments.
///
/// If the first value is `PUB` or `DART` (case-sensitive), it will be replaced
/// with the full, platform-specific path to the corresponding executable in the
/// currently executing SDK.
///
/// If [afterBuildCommand] is specified, it will be run after the build and
/// has the same behavior as [customCommand].
///
/// If provided, [gitDiffPathArguments] are passed as `-- <path>` to `git diff`.
/// This can be useful if you want to include certain files from the diff
/// calculation.
///
/// For example `[':!pubspec.lock']` can be used to ignore changes to the
/// `pubspec.lock` file.
Future<void> expectBuildClean({
  String? packageRelativeDirectory,
  List<String> customCommand = defaultCommand,
  List<String>? afterBuildCommand,
  List<String>? gitDiffPathArguments,
}) => expectBuildCleanImpl(
  Directory.current.resolveSymbolicLinksSync(),
  command: customCommand,
  afterBuildCommand: afterBuildCommand,
  packageRelativeDirectory: packageRelativeDirectory,
  gitDiffPathArguments: gitDiffPathArguments,
);
