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
    await d.dir('package_a', [
      getPubspecYamlFile('package_a'),
      d.dir('lib', [
        d.dir('src', [
          getGeneratedVersionFile('1.2.3'),
        ])
      ])
    ]).create();

    await d.dir('package_b', [
      getPubspecYamlFile('package_b'),
      d.dir('lib', [
        d.dir('src', [
          getGeneratedVersionFile('1.2.3'),
        ])
      ])
    ]).create();

    final gitDir = await GitDir.init(d.sandbox, allowContent: true);
    await gitDir.runCommand(['add', '.']);
    await gitDir.runCommand(['commit', '-am', 'test']);

    final packageAProcess = await TestProcess.start(
      dartPath,
      ['pub', 'get'],
      workingDirectory: '${d.sandbox}/package_a',
    );

    await packageAProcess.shouldExit(0);

    final packageBProcess = await TestProcess.start(
      dartPath,
      ['pub', 'get'],
      workingDirectory: '${d.sandbox}/package_b',
    );

    await packageBProcess.shouldExit(0);
  });

  test(
    'when they have no modification, package a and b tests should pass',
    () async {
      await expectBuildCleanImpl(
        '${d.sandbox}/package_a',
        defaultCommand,
        packageRelativeDirectory: 'package_a',
      );
      await expectBuildCleanImpl(
        '${d.sandbox}/package_b',
        defaultCommand,
        packageRelativeDirectory: 'package_b',
      );
    },
  );

  test(
    '''when package b has modifications,
      package a test should pass and package b test should fail''',
    () async {
      await d.dir('package_b', [
        getPubspecYamlFile('package_b'),
        d.dir('lib', [
          d.dir('src', [
            getGeneratedVersionFile('1.2.4'),
          ])
        ])
      ]).create();

      await expectBuildCleanImpl(
        '${d.sandbox}/package_a',
        defaultCommand,
        packageRelativeDirectory: 'package_a',
      );

      expect(
        () => expectBuildCleanImpl(
          '${d.sandbox}/package_b',
          defaultCommand,
          packageRelativeDirectory: 'package_b',
        ),
        throwsA(const TypeMatcher<TestFailure>()),
      );
    },
  );
}
