@Timeout.factor(4)

import 'package:build_verify/build_verify.dart' show defaultCommand;
import 'package:build_verify/src/impl.dart';
import 'package:build_verify/src/utils.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

void main() {
  setUp(() async {
    await d.file('pubspec.yaml', '''
name: example
version: 1.2.3
environment:
  sdk: '>=2.0.0 <3.0.0'

dev_dependencies:
  build_runner: ^1.0.0
  build_version: ^2.0.0
''').create();

    await d.dir('lib', [
      d.dir('src', [
        d.file('version.dart', r'''
// Generated code. Do not modify.
const packageVersion = '1.2.3';
''')
      ])
    ]).create();

    final gitDir = await GitDir.init(d.sandbox, allowContent: true);
    await gitDir.runCommand(['add', '.']);
    await gitDir.runCommand(['commit', '-am', 'test']);

    final process = await TestProcess.start(
        pubPath, ['get', '--offline', '--no-precompile'],
        workingDirectory: d.sandbox);

    await process.shouldExit(0);
  });

  test('succes unit test', () async {
    expectBuildCleanImpl(d.sandbox, defaultCommand);
  });
}
