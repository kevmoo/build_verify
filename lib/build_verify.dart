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
/// If the first value is `DART` (case-sensitive), it will be replaced
/// with the path to the `dart` executable in the current SDK (or `'dart'`
/// if no SDK path could be resolved).
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
  List<String>? gitDiffPathArguments,
}) => expectBuildCleanImpl(
  Directory.current.resolveSymbolicLinksSync(),
  command: customCommand,
  packageRelativeDirectory: packageRelativeDirectory,
  gitDiffPathArguments: gitDiffPathArguments,
);
