[![Build Status](https://travis-ci.org/kevmoo/build_verify.svg?branch=master)](https://travis-ci.org/kevmoo/build_verify)

Test utility to ensure generated Dart code within a package is up-to-date
when using `package:build`.

### Usage

Assuming your package is already configured to use `package:build_runner` –
`pub run build_runner build` succeeds – then simply add a unit test to the
test directory.

For example: `test/ensure_build_test.dart` containing:

```dart
import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test('ensure_build', expectBuildClean);
}
```
