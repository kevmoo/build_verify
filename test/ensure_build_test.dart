@Tags(['presubmit-only'])
library;

import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test('ensure_build', expectBuildClean, timeout: const Timeout.factor(2));
}
