import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart' as ansi;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'utils.dart';

const dartPlaceHolder = 'DART';

Future<void> expectBuildCleanImpl(
  String workingDir,
  List<String> command, {
  String? packageRelativeDirectory,
}) async {
  if (command.isEmpty) {
    throw ArgumentError.value(command, 'customCommand', 'Cannot be empty');
  }

  final repoRoot =
      await _runProc('git', ['rev-parse', '--show-toplevel'], workingDir);
  final pkgDir = p.join(repoRoot, packageRelativeDirectory);
  if (!p.equals(pkgDir, workingDir)) {
    throw StateError(
      'Expected the git root ($repoRoot) '
      'to match the current directory ($workingDir).',
    );
  }

  // 1 - get a list of modified files files - should be empty
  expect(
    await _changedGeneratedFiles(workingDir),
    isEmpty,
    reason: 'The working directory should be clean before running build.',
  );

  var executable = command.first;
  if (executable == 'DART') {
    executable = dartPath;
  }

  final arguments = command.skip(1).toList();

  // 2 - run build - should be no output, since nothing should change
  final result = await _runProc(executable, arguments, workingDir);

  expectResultOutputSucceeds(result);

  // 3 - get a list of modified files after the build - should still be empty
  expect(await _changedGeneratedFiles(workingDir), isEmpty);
}

void expectResultOutputSucceeds(String result) {
  expect(
    result,
    contains(RegExp(r'\[INFO\] Succeeded after .+ with \d+ outputs')),
  );
}

Future<String> _changedGeneratedFiles(String workingDir) =>
    _runProc('git', ['diff', ':!pubspec.lock'], workingDir);

Future<String> _runProc(
  String proc,
  List<String> args,
  String workingDir,
) async {
  print(
    'Running: `${ansi.cyan.wrap(
      [proc, ...args].join(' '),
    )}` in `${ansi.cyan.wrap(workingDir)}`',
  );

  final process = await Process.start(proc, args, workingDirectory: workingDir);

  Future<void> transform(
    Stream<List<int>> standardChannel,
    List<String> lines,
  ) =>
      standardChannel
          .transform(const SystemEncoding().decoder)
          .transform(const LineSplitter())
          .forEach((element) {
        print(element);
        lines.add(element);
      });

  final stdoutContent = <String>[];
  final stderrContent = <String>[];

  final result = await Future.wait([
    process.exitCode,
    transform(process.stderr, stderrContent),
    transform(process.stdout, stdoutContent),
  ]);

  final exitCode = result.first as int;

  if (exitCode != 0) {
    throw ProcessException(proc, args, 'Process failed', exitCode);
  }

  return stdoutContent.join('\n').trim();
}
