import 'package:test/test.dart';

final throwsATestFailure = throwsA(
  const TypeMatcher<TestFailure>().having(
    (p0) => p0.message,
    'message',
    isNotEmpty,
  ),
);
