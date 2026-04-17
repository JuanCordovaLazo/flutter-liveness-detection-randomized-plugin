import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LivenessFaceOrientationHelper', () {
    test('detects a face looking forward within threshold', () {
      final isFacingForward = LivenessFaceOrientationHelper.isFacingForward(
        headEulerAngleX: 6,
        headEulerAngleY: -7,
      );

      expect(isFacingForward, isTrue);
    });

    test('rejects a face when pitch is out of threshold', () {
      final isFacingForward = LivenessFaceOrientationHelper.isFacingForward(
        headEulerAngleX: 16,
        headEulerAngleY: 2,
      );

      expect(isFacingForward, isFalse);
    });

    test('rejects a face when yaw is out of threshold', () {
      final isFacingForward = LivenessFaceOrientationHelper.isFacingForward(
        headEulerAngleX: 2,
        headEulerAngleY: 13,
      );

      expect(isFacingForward, isFalse);
    });

    test('requires the lookForward hold duration to be satisfied', () {
      final startedAt = DateTime(2026, 1, 1, 10, 0, 0, 0, 0);
      final beforeHoldEnds = startedAt.add(const Duration(milliseconds: 399));
      final afterHoldEnds = startedAt.add(const Duration(milliseconds: 400));

      expect(
        LivenessFaceOrientationHelper.hasSatisfiedLookForwardHold(
          startedAt: startedAt,
          now: beforeHoldEnds,
        ),
        isFalse,
      );
      expect(
        LivenessFaceOrientationHelper.hasSatisfiedLookForwardHold(
          startedAt: startedAt,
          now: afterHoldEnds,
        ),
        isTrue,
      );
    });
  });
}
