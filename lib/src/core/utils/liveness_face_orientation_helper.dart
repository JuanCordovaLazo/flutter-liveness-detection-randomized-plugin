import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

class LivenessFaceOrientationHelper {
  static const double defaultForwardYawThreshold = 12.0;
  static const double defaultForwardPitchThreshold = 12.0;
  static const Duration defaultLookForwardHoldDuration = Duration(
    milliseconds: 400,
  );

  static bool isFacingForward({
    required double? headEulerAngleX,
    required double? headEulerAngleY,
    double maxPitch = defaultForwardPitchThreshold,
    double maxYaw = defaultForwardYawThreshold,
  }) {
    final double pitch = (headEulerAngleX ?? 0).abs();
    final double yaw = (headEulerAngleY ?? 0).abs();

    return pitch < maxPitch && yaw < maxYaw;
  }

  static bool hasSatisfiedLookForwardHold({
    required DateTime startedAt,
    required DateTime now,
    Duration holdDuration = defaultLookForwardHoldDuration,
  }) {
    return now.difference(startedAt) >= holdDuration;
  }

  static bool isFaceAlignedForStep({
    required LivenessDetectionStep step,
    required Face face,
    double maxPitch = defaultForwardPitchThreshold,
    double maxYaw = defaultForwardYawThreshold,
  }) {
    if (step != LivenessDetectionStep.lookForward) {
      return false;
    }

    return isFacingForward(
      headEulerAngleX: face.headEulerAngleX,
      headEulerAngleY: face.headEulerAngleY,
      maxPitch: maxPitch,
      maxYaw: maxYaw,
    );
  }
}
