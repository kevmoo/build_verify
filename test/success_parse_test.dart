import 'package:build_verify/src/impl.dart';
import 'package:test/test.dart';

void main() {
  for (var duration in [
    const Duration(milliseconds: 99),
    const Duration(seconds: 45),
    const Duration(minutes: 45),
    const Duration(hours: 52),
  ]) {
    test(_humanReadable(duration), () {
      final output =
          '[INFO] Succeeded after ${_humanReadable(duration)} with 52 outputs';

      expectResultOutputSucceeds(output);
    });

    test('failing output with ${_humanReadable(duration)}', () {
      final output = '[INFO] Failed after ${_humanReadable(duration)}';

      expect(
        () => expectResultOutputSucceeds(output),
        throwsA(const TypeMatcher<TestFailure>()),
      );
    });
  }
}

// Copied from
// https://github.com/dart-lang/build/blob/a337a908a25e4d1bd06e898f40c3c013a7ec04e3/build_runner_core/lib/src/logging/human_readable_duration.dart

/// Returns a human readable string for a duration.
///
/// Handles durations that span up to hours - this will not be a good fit for
/// durations that are longer than days.
///
/// Always attempts 2 'levels' of precision. Will show hours/minutes,
/// minutes/seconds, seconds/tenths of a second, or milliseconds depending on
/// the largest level that needs to be displayed.
String _humanReadable(Duration duration) {
  if (duration < const Duration(seconds: 1)) {
    return '${duration.inMilliseconds}ms';
  }
  if (duration < const Duration(minutes: 1)) {
    return '${(duration.inMilliseconds / 1000.0).toStringAsFixed(1)}s';
  }
  if (duration < const Duration(hours: 1)) {
    final minutes = duration.inMinutes;
    final remaining = duration - Duration(minutes: minutes);
    return '${minutes}m ${remaining.inSeconds}s';
  }
  final hours = duration.inHours;
  final remaining = duration - Duration(hours: hours);
  return '${hours}h ${remaining.inMinutes}m';
}
