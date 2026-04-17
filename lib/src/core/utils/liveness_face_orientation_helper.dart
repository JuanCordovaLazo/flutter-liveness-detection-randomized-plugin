import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

class LivenessFaceOrientationHelper {
  static const double defaultForwardYawThreshold = 12.0;
  static const double defaultForwardPitchThreshold = 12.0;
  static const double defaultSideTurnYawThreshold = 16.0;
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

  static bool hasExceededFaceLossGracePeriod({
    required int faceLossFrameCount,
    required int gracePeriodFrames,
  }) {
    return faceLossFrameCount >= gracePeriodFrames;
  }

  static bool isHeadTurnedForStep({
    required LivenessDetectionStep step,
    required double? headEulerAngleY,
    double minYawThreshold = defaultSideTurnYawThreshold,
    required bool isIOS,
  }) {
    final double yaw = headEulerAngleY ?? 0;

    switch (step) {
      case LivenessDetectionStep.lookRight:
        return isIOS ? yaw > minYawThreshold : yaw < -minYawThreshold;
      case LivenessDetectionStep.lookLeft:
        return isIOS ? yaw < -minYawThreshold : yaw > minYawThreshold;
      default:
        return false;
    }
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
