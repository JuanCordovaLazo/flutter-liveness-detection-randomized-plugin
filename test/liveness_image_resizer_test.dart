import 'package:flutter_liveness_detection_randomized_plugin/src/core/utils/liveness_image_resizer.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('shouldPostProcessCapturedImage', () {
    test(
      'returns false when quality is high and no resize constraints exist',
      () {
        expect(shouldPostProcessCapturedImage(quality: 100), isFalse);
      },
    );

    test(
      'returns true when resize constraints exist even with high quality',
      () {
        expect(
          shouldPostProcessCapturedImage(quality: 100, maxWidth: 1024),
          isTrue,
        );
      },
    );
  });

  group('calculateTargetImageSize', () {
    test('keeps original dimensions when no limits are provided', () {
      expect(
        calculateTargetImageSize(width: 1920, height: 1080),
        const LivenessImageTargetSize(width: 1920, height: 1080),
      );
    });

    test('resizes using maxWidth while preserving aspect ratio', () {
      expect(
        calculateTargetImageSize(width: 1920, height: 1080, maxWidth: 1024),
        const LivenessImageTargetSize(width: 1024, height: 576),
      );
    });

    test('resizes using bounding box constraints', () {
      expect(
        calculateTargetImageSize(
          width: 1920,
          height: 1080,
          maxWidth: 1000,
          maxHeight: 500,
        ),
        const LivenessImageTargetSize(width: 888, height: 500),
      );
    });

    test('does not upscale smaller images', () {
      expect(
        calculateTargetImageSize(width: 640, height: 480, maxWidth: 1024),
        const LivenessImageTargetSize(width: 640, height: 480),
      );
    });
  });

  group('resizeImageIfNeeded', () {
    test('returns resized image within bounds', () {
      final source = img.Image(width: 1920, height: 1080);

      final resized = resizeImageIfNeeded(
        image: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      expect(resized.width, 1024);
      expect(resized.height, 576);
    });
  });

  group('LivenessDetectionConfig', () {
    test('accepts valid resize limits', () {
      expect(
        LivenessDetectionConfig(
          maxWidth: 1024,
          maxHeight: 1024,
          faceLossGraceFrames: 3,
          frameProcessingInterval: const Duration(milliseconds: 100),
        ),
        isA<LivenessDetectionConfig>(),
      );
    });

    test('rejects non-positive maxWidth', () {
      expect(
        () => LivenessDetectionConfig(maxWidth: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects non-positive maxHeight', () {
      expect(
        () => LivenessDetectionConfig(maxHeight: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
