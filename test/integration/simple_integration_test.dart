@Timeout.factor(4)

import 'package:build_verify/build_verify.dart' show defaultCommand;
import 'package:build_verify/src/impl.dart';
import 'package:build_verify/src/utils.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

import 'helpers.dart';

void main() {
  setUp(() async {
    await getPubspecYamlFile('example').create();

    await d.dir('lib', [
      d.dir('src', [
        getGeneratedVersionFile('1.2.3'),
      ])
    ]).create();

    final gitDir = await GitDir.init(d.sandbox, allowContent: true);
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
    await expectBuildCleanImpl(d.sandbox, defaultCommand);
  });
}
