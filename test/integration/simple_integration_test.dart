@Timeout.factor(4)
library;

import 'dart:io';

import 'package:build_verify/src/impl.dart';
import 'package:build_verify/src/utils.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

import '../test_shared.dart';
import 'helpers.dart';

void main() {
  late GitDir gitDir;

  setUp(() async {
    await getPubspecYamlFile('example').create();

    await d.dir('lib', [
      d.dir('src', [
        getGeneratedVersionFile(),
      ]),
    ]).create();

    gitDir = await GitDir.init(d.sandbox, allowContent: true);
    await gitDir.runCommand(['add', '.']);
    await gitDir.runCommand(['commit', '-am', 'test']);

    final process = await TestProcess.start(
      dartPath,
      ['pub', 'get'],
      workingDirectory: d.sandbox,
    );

    await process.shouldExit(0);
  });

  test('success unit test', () async {
    await expectBuildCleanImpl(d.sandbox);
  });

  group('when a file changes', () {
    setUp(() async {
      await gitDir.runCommand(['add', 'pubspec.lock']);
      await gitDir.runCommand(['commit', '-am', 'commit pubspec']);

      final lockFile = d.file('pubspec.lock').io;

      final sink = lockFile.openWrite(mode: FileMode.writeOnlyAppend)
        ..writeln('\n# not interesting update');
      await sink.flush();
      await sink.close();
    });
    test('should fail', () async {
      await expectLater(
        expectBuildCleanImpl(d.sandbox),
        throwsATestFailure,
      );
    });
    test('should not fail if ignored', () async {
      await expectBuildCleanImpl(
        d.sandbox,
        gitDiffPathArguments: [':!pubspec.lock'],
      );
    });
  });
}
