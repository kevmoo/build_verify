import 'dart:io';

import 'package:path/path.dart' as p;

/// The path to the root directory of the SDK.
final String dartPath = (() {
  final executableBaseName = p.basename(Platform.resolvedExecutable);

  if (executableBaseName == 'flutter_tester' ||
      executableBaseName == 'flutter_tester.exe') {
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;

    return p.join(flutterRoot, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
  } else {
    assert(
      executableBaseName == 'dart' || executableBaseName == 'dart.exe',
      'Was not expected "$executableBaseName".',
    );
    return Platform.resolvedExecutable;
  }
})();
