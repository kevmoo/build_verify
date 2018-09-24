import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'src/utils.dart';

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
  var repoRoot = _runProc('git', ['rev-parse', '--show-toplevel']);
  var currentDir = Directory.current.resolveSymbolicLinksSync();

  var pkgDir = p.join(repoRoot, packageRelativeDirectory);

  if (!p.equals(pkgDir, currentDir)) {
    throw StateError('Expected the git root ($repoRoot) '
        'to match the current directory ($currentDir).');
  }

  customCommand ??= defaultCommand;

  if (customCommand.isEmpty) {
    throw ArgumentError.value(
        customCommand, 'customCommand', 'Cannot be empty');
  }

  // 1 - get a list of modified files files - should be empty
  expect(_changedGeneratedFiles(), isEmpty);

  var executable = customCommand.first;
  if (executable == 'PUB') {
    executable = pubPath;
  } else if (executable == 'DART') {
    executable = dartPath;
  }

  var arguments = customCommand.skip(1).toList();

  // 2 - run build - should be no output, since nothing should change
  var result = _runProc(executable, arguments);

  printOnFailure(result);
  expect(result,
      contains(RegExp(r'\[INFO\] Succeeded after \S+ with \d+ outputs')));

  // 3 - get a list of modified files after the build - should still be empty
  expect(_changedGeneratedFiles(), isEmpty);
}

final _whitespace = RegExp(r'\s');

Set<String> _changedGeneratedFiles() {
  var output = _runProc('git', ['status', '--porcelain']);

  return LineSplitter.split(output)
      .map((line) => line.split(_whitespace).last)
      .where((path) => path.endsWith('.dart'))
      .toSet();
}

String _runProc(String proc, List<String> args) {
  var result = Process.runSync(proc, args);

  if (result.exitCode != 0) {
    throw ProcessException(
        proc, args, result.stderr as String, result.exitCode);
  }

  return (result.stdout as String).trim();
}
