import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LivenessChallengeFlowBuilder', () {
    test('preserves customized order exactly when mustShuffle is false', () {
      final config = LivenessDetectionConfig(
        useCustomizedLabel: true,
        mustShuffle: false,
        customizedLabel: LivenessDetectionLabelModel(
          blink: 'Blink',
          lookUp: 'Look Up',
          lookDown: '',
          lookRight: 'Look Right',
          lookLeft: '',
          smile: 'Smile',
          lookForward: 'Look Forward',
        ),
      );

      final steps = LivenessChallengeFlowBuilder.buildSteps(config: config);

      expect(
        steps.map((step) => step.step).toList(),
        equals([
          LivenessDetectionStep.blink,
          LivenessDetectionStep.lookUp,
          LivenessDetectionStep.lookRight,
          LivenessDetectionStep.smile,
          LivenessDetectionStep.lookForward,
        ]),
      );
    });

    test(
      'keeps smile last when mustShuffle is true and lastChallenge is smile',
      () {
        final config = LivenessDetectionConfig(
          useCustomizedLabel: true,
          mustShuffle: true,
          lastChallenge: LivenessDetectionStep.smile,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink',
            lookUp: 'Look Up',
            lookDown: 'Look Down',
            lookRight: 'Look Right',
            lookLeft: 'Look Left',
            smile: 'Smile',
          ),
        );

        final steps = LivenessChallengeFlowBuilder.buildSteps(
          config: config,
          random: Random(7),
        );

        expect(steps.last.step, LivenessDetectionStep.smile);
        expect(
          steps
              .where((step) => step.step == LivenessDetectionStep.smile)
              .length,
          1,
        );
      },
    );

    test('keeps lookForward last when mustShuffle is true', () {
      final config = LivenessDetectionConfig(
        useCustomizedLabel: true,
        mustShuffle: true,
        lastChallenge: LivenessDetectionStep.lookForward,
        customizedLabel: LivenessDetectionLabelModel(
          blink: 'Blink',
          lookUp: 'Look Up',
          lookRight: 'Look Right',
          smile: 'Smile',
          lookForward: 'Look Forward',
        ),
      );

      final steps = LivenessChallengeFlowBuilder.buildSteps(
        config: config,
        random: Random(11),
      );

      expect(steps.last.step, LivenessDetectionStep.lookForward);
      expect(
        steps
            .where((step) => step.step == LivenessDetectionStep.lookForward)
            .length,
        1,
      );
    });

    test(
      'ignores lastChallenge when it is not enabled in the effective list',
      () {
        final config = LivenessDetectionConfig(
          useCustomizedLabel: true,
          mustShuffle: true,
          lastChallenge: LivenessDetectionStep.lookForward,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink',
            lookUp: 'Look Up',
            lookDown: '',
            lookRight: 'Look Right',
            lookLeft: '',
            smile: 'Smile',
            lookForward: '',
          ),
        );

        final steps = LivenessChallengeFlowBuilder.buildSteps(
          config: config,
          random: Random(5),
        );

        expect(
          steps.any((step) => step.step == LivenessDetectionStep.lookForward),
          isFalse,
        );
        expect(steps.length, 4);
      },
    );

    test(
      'does not force smile last when deprecated shuffleListWithSmileLast is set',
      () {
        final config = LivenessDetectionConfig(
          useCustomizedLabel: false,
          mustShuffle: true,
          // ignore: deprecated_member_use_from_same_package
          shuffleListWithSmileLast: true,
        );

        final steps = LivenessChallengeFlowBuilder.buildSteps(
          config: config,
          random: Random(3),
        );

        expect(steps.last.step, isNot(LivenessDetectionStep.smile));
      },
    );

    test('does not introduce duplicates for the last challenge', () {
      final ordered = LivenessChallengeFlowBuilder.orderSteps(
        steps: [
          LivenessDetectionStepItem(
            step: LivenessDetectionStep.blink,
            title: 'Blink',
          ),
          LivenessDetectionStepItem(
            step: LivenessDetectionStep.lookForward,
            title: 'Look Forward',
          ),
          LivenessDetectionStepItem(
            step: LivenessDetectionStep.smile,
            title: 'Smile',
          ),
        ],
        mustShuffle: false,
        lastChallenge: LivenessDetectionStep.lookForward,
      );

      expect(
        ordered
            .where((step) => step.step == LivenessDetectionStep.lookForward)
            .length,
        1,
      );
      expect(ordered.last.step, LivenessDetectionStep.lookForward);
    });

    test('uses the configured photo challenge when it exists', () {
      final config = LivenessDetectionConfig(
        useCustomizedLabel: true,
        mustShuffle: false,
        takePhotoOnChallenge: LivenessDetectionStep.lookForward,
        customizedLabel: LivenessDetectionLabelModel(
          blink: 'Blink',
          lookUp: 'Look Up',
          lookRight: 'Look Right',
          smile: 'Smile',
          lookForward: 'Look Forward',
        ),
      );

      final steps = LivenessChallengeFlowBuilder.buildSteps(config: config);
      final takePhotoOnChallenge =
          LivenessChallengeFlowBuilder.resolveTakePhotoOnChallenge(
            config: config,
            steps: steps,
          );

      expect(takePhotoOnChallenge, LivenessDetectionStep.lookForward);
    });

    test(
      'falls back to the last effective challenge when photo challenge is absent',
      () {
        final config = LivenessDetectionConfig(
          useCustomizedLabel: true,
          mustShuffle: false,
          takePhotoOnChallenge: LivenessDetectionStep.lookForward,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink',
            lookUp: 'Look Up',
            lookRight: 'Look Right',
            smile: 'Smile',
            lookForward: '',
          ),
        );

        final steps = LivenessChallengeFlowBuilder.buildSteps(config: config);
        final takePhotoOnChallenge =
            LivenessChallengeFlowBuilder.resolveTakePhotoOnChallenge(
              config: config,
              steps: steps,
            );

        expect(takePhotoOnChallenge, LivenessDetectionStep.smile);
      },
    );
  });
}
