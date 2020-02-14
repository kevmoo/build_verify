import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'utils.dart';

const pubPlaceHolder = 'PUB';

void expectBuildCleanImpl(
  String workingDir,
  List<String> command, {
  String packageRelativeDirectory,
}) {
  if (command.isEmpty) {
    throw ArgumentError.value(command, 'customCommand', 'Cannot be empty');
  }

  final repoRoot =
      _runProc('git', ['rev-parse', '--show-toplevel'], workingDir);
  final pkgDir = p.join(repoRoot, packageRelativeDirectory);
  if (!p.equals(pkgDir, workingDir)) {
    throw StateError('Expected the git root ($repoRoot) '
        'to match the current directory ($workingDir).');
  }

  // 1 - get a list of modified files files - should be empty
  expect(_changedGeneratedFiles(workingDir), isEmpty);

  var executable = command.first;
  if (executable == pubPlaceHolder) {
    executable = pubPath;
  } else if (executable == 'DART') {
    executable = dartPath;
  }

  final arguments = command.skip(1).toList();

  // 2 - run build - should be no output, since nothing should change
  final result = _runProc(executable, arguments, workingDir);

  expectResultOutputSucceeds(result);

  // 3 - get a list of modified files after the build - should still be empty
  expect(_changedGeneratedFiles(workingDir), isEmpty);
}

void expectResultOutputSucceeds(String result) {
  expect(result,
      contains(RegExp(r'\[INFO\] Succeeded after .+ with \d+ outputs')));
}

final _whitespace = RegExp(r'\s');

Set<String> _changedGeneratedFiles(String workingDir) {
  final output = _runProc('git', ['status', '--porcelain'], workingDir);

  return LineSplitter.split(output)
      .map((line) => line.split(_whitespace).last)
      .where((path) => path.endsWith('.dart'))
      .toSet();
}

String _runProc(String proc, List<String> args, String workingDir) {
  final result = Process.runSync(proc, args, workingDirectory: workingDir);

  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    throw ProcessException(proc, args, 'Process failed', result.exitCode);
  }

  return (result.stdout as String).trim();
}
