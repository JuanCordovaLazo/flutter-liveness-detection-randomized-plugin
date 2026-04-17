import 'dart:math';

import 'package:flutter_liveness_detection_randomized_plugin/src/core/constants/liveness_detection_step_constant.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/core/enums/liveness_detection_step.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_config.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_label_model.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_step_item.dart';

class LivenessChallengeFlowBuilder {
  static List<LivenessDetectionStepItem> buildSteps({
    required LivenessDetectionConfig config,
    List<LivenessDetectionStepItem>? defaultSteps,
    Random? random,
  }) {
    final List<LivenessDetectionStepItem> baseSteps =
        config.useCustomizedLabel && config.customizedLabel != null
        ? buildCustomizedSteps(config.customizedLabel!)
        : _cloneSteps(defaultSteps ?? stepLiveness);

    return orderSteps(
      steps: baseSteps,
      mustShuffle: config.mustShuffle ?? true,
      lastChallenge: _resolveEffectiveLastChallenge(config: config),
      random: random,
    );
  }

  static List<LivenessDetectionStepItem> buildCustomizedSteps(
    LivenessDetectionLabelModel label,
  ) {
    final List<_CustomizedStepLabel> orderedLabels = [
      _CustomizedStepLabel(
        step: LivenessDetectionStep.blink,
        label: label.blink,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.lookUp,
        label: label.lookUp,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.lookDown,
        label: label.lookDown,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.lookRight,
        label: label.lookRight,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.lookLeft,
        label: label.lookLeft,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.smile,
        label: label.smile,
      ),
      _CustomizedStepLabel(
        step: LivenessDetectionStep.lookForward,
        label: label.lookForward,
      ),
    ];

    return orderedLabels
        .where((item) => item.label != '')
        .map(
          (item) => LivenessDetectionStepItem(
            step: item.step,
            title: item.label ?? getDefaultLivenessStepTitle(item.step),
          ),
        )
        .toList(growable: false);
  }

  static List<LivenessDetectionStepItem> orderSteps({
    required List<LivenessDetectionStepItem> steps,
    required bool mustShuffle,
    required LivenessDetectionStep? lastChallenge,
    Random? random,
  }) {
    final List<LivenessDetectionStepItem> orderedSteps = _cloneSteps(steps);

    final int lastChallengeIndex = lastChallenge == null
        ? -1
        : orderedSteps.indexWhere((item) => item.step == lastChallenge);

    LivenessDetectionStepItem? finalStep;
    if (lastChallengeIndex != -1) {
      finalStep = orderedSteps.removeAt(lastChallengeIndex);
    }

    if (mustShuffle && orderedSteps.length > 1) {
      _shuffle(orderedSteps, random ?? Random());
    }

    if (finalStep != null &&
        orderedSteps.every((item) => item.step != finalStep!.step)) {
      orderedSteps.add(finalStep);
    }

    return orderedSteps;
  }

  static LivenessDetectionStep? resolveTakePhotoOnChallenge({
    required LivenessDetectionConfig config,
    required List<LivenessDetectionStepItem> steps,
  }) {
    if (steps.isEmpty) {
      return null;
    }

    final LivenessDetectionStep? configuredChallenge =
        config.takePhotoOnChallenge;
    if (configuredChallenge != null &&
        steps.any((item) => item.step == configuredChallenge)) {
      return configuredChallenge;
    }

    return steps.last.step;
  }

  static LivenessDetectionStep? _resolveEffectiveLastChallenge({
    required LivenessDetectionConfig config,
  }) {
    if (config.lastChallenge != null) {
      return config.lastChallenge;
    }

    final bool shouldShuffle = config.mustShuffle ?? true;
    // ignore: deprecated_member_use_from_same_package
    if (shouldShuffle && config.shuffleListWithSmileLast) {
      return LivenessDetectionStep.smile;
    }

    return null;
  }

  static List<LivenessDetectionStepItem> _cloneSteps(
    List<LivenessDetectionStepItem> steps,
  ) {
    return steps.map((step) => step.copyWith()).toList();
  }

  static void _shuffle(List<LivenessDetectionStepItem> steps, Random random) {
    for (int index = steps.length - 1; index > 0; index--) {
      final int randomIndex = random.nextInt(index + 1);
      final LivenessDetectionStepItem currentItem = steps[index];
      steps[index] = steps[randomIndex];
      steps[randomIndex] = currentItem;
    }
  }
}

class _CustomizedStepLabel {
  final LivenessDetectionStep step;
  final String? label;

  const _CustomizedStepLabel({required this.step, required this.label});
}
