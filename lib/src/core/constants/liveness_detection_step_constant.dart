import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

String getDefaultLivenessStepTitle(LivenessDetectionStep step) {
  switch (step) {
    case LivenessDetectionStep.blink:
      return 'Blink 2-3 Times';
    case LivenessDetectionStep.lookUp:
      return 'Look UP';
    case LivenessDetectionStep.lookDown:
      return 'Look DOWN';
    case LivenessDetectionStep.lookRight:
      return 'Look RIGHT';
    case LivenessDetectionStep.lookLeft:
      return 'Look LEFT';
    case LivenessDetectionStep.smile:
      return 'Smile';
    case LivenessDetectionStep.lookForward:
      return 'Look Forward';
  }
}

List<LivenessDetectionStepItem> stepLiveness = [
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.blink,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.blink),
  ),
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.lookUp,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.lookUp),
  ),
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.lookDown,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.lookDown),
  ),
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.lookRight,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.lookRight),
  ),
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.lookLeft,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.lookLeft),
  ),
  LivenessDetectionStepItem(
    step: LivenessDetectionStep.smile,
    title: getDefaultLivenessStepTitle(LivenessDetectionStep.smile),
  ),
];
