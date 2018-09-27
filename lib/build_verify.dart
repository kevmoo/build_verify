import 'src/impl.dart';

const defaultCommand = [
  'PUB',
  'run',
  'build_runner',
  'build',
  '--delete-conflicting-outputs'
];

/// If [customCommand] is not specified, [defaultCommand] is used.
///
/// The first item in [customCommand] is used as the executable to run. The
/// remaining values are used as the executable arguments.
///
/// If the first value is `PUB` or `DART`, it will be replaced with the full,
/// platform-specific path to the corresponding executable in the currently
/// executing SDK.
void expectBuildClean(
    {String packageRelativeDirectory,
    List<String> customCommand = defaultCommand}) {
  return expectBuildCleanImpl(customCommand ?? defaultCommand,
      packageRelativeDirectory: packageRelativeDirectory);
}
