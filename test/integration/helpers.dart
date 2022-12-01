import 'package:test_descriptor/test_descriptor.dart' as d;

const exampleVersion = '1.2.3';

d.FileDescriptor getPubspecYamlFile(String packageName) => d.file(
      'pubspec.yaml',
      '''
name: $packageName
version: $exampleVersion
environment:
  sdk: '>=2.12.0 <3.0.0'

dev_dependencies:
  build_runner: ^2.0.0
  build_version: ^2.0.0
''',
    );

d.FileDescriptor getGeneratedVersionFile({String version = exampleVersion}) =>
    d.file(
      'version.dart',
      '''
// Generated code. Do not modify.
const packageVersion = '$version';
''',
    );
