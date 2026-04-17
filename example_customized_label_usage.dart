// Example of correct customizedLabel usage

// ignore_for_file: unused_local_variable

import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

void exampleUsage() {
  // ✅ CORRECT: Skip blink and lookDown, use custom labels for others
  final config1 = LivenessDetectionConfig(
    useCustomizedLabel: true,
    mustShuffle: false,
    backButtonText: 'Volver',
    userFaceFoundText: 'Rostro detectado',
    userFaceNotFoundText: 'Rostro no detectado',
    customizedLabel: LivenessDetectionLabelModel(
      blink: '', // Empty string = skip this challenge
      lookUp: 'Tengok Atas', // Custom label
      lookDown: '', // Empty string = skip this challenge
      lookRight: null, // null = use default label "Look RIGHT"
      lookLeft: null, // null = use default label "Look LEFT"
      smile: 'Senyum Dong!', // Custom label
      lookForward: 'Hadap Depan', // Final alignment before capture
    ),
  );
  // Result: Only lookUp, lookRight, lookLeft, smile, lookForward challenges appear in declared order

  // ✅ CORRECT: Use all challenges with custom labels
  final config2 = LivenessDetectionConfig(
    useCustomizedLabel: true,
    mustShuffle: true,
    lastChallenge: LivenessDetectionStep.lookForward,
    takePhotoOnChallenge: LivenessDetectionStep.lookForward,
    backButtonText: 'Volver',
    userFaceFoundText: 'Rostro detectado',
    userFaceNotFoundText: 'Rostro no detectado',
    customizedLabel: LivenessDetectionLabelModel(
      blink: 'Kedipkan Mata',
      lookUp: 'Lihat Atas',
      lookDown: 'Lihat Bawah',
      lookRight: 'Lihat Kanan',
      lookLeft: 'Lihat Kiri',
      smile: 'Tersenyum',
      lookForward: 'Lurus ke Kamera',
    ),
  );
  // Result: The flow is shuffled, but lookForward always stays as the final step

  // ✅ CORRECT: Mix of custom, default, and skipped
  final config3 = LivenessDetectionConfig(
    useCustomizedLabel: true,
    mustShuffle: true,
    lastChallenge: LivenessDetectionStep.smile,
    customizedLabel: LivenessDetectionLabelModel(
      blink: null, // Use default "Blink 2-3 Times"
      lookUp: '', // Skip
      lookDown: '', // Skip
      lookRight: 'Turn Right Please',
      lookLeft: 'Turn Left Please',
      smile: null, // Use default "Smile"
      lookForward: '', // Skip
    ),
  );
  // Result: Only blink, lookLeft, lookRight, smile challenges

  // ❌ WRONG: This will throw assertion error
  // final configWrong = LivenessDetectionConfig(
  //   useCustomizedLabel: true,
  //   customizedLabel: null, // ERROR: Cannot be null when useCustomizedLabel is true
  // );

  // ✅ CORRECT: Use default behavior
  final config4 = LivenessDetectionConfig(
    useCustomizedLabel: false, // customizedLabel will be ignored
    mustShuffle: true,
  );

  // ✅ CORRECT: New flow control with explicit ordering and no shuffle
  final config5 = LivenessDetectionConfig(
    useCustomizedLabel: true,
    mustShuffle: false,
    lastChallenge: LivenessDetectionStep.lookForward,
    takePhotoOnChallenge: LivenessDetectionStep.lookForward,
    customizedLabel: LivenessDetectionLabelModel(
      blink: 'Step 1',
      lookUp: 'Step 2',
      lookDown: '',
      lookRight: 'Step 3',
      lookLeft: '',
      smile: 'Step 4',
      lookForward: 'Final Step',
    ),
  );

  // ✅ CORRECT: Capture on lookForward, then continue to a final smile step
  final config6 = LivenessDetectionConfig(
    useCustomizedLabel: true,
    mustShuffle: false,
    lastChallenge: LivenessDetectionStep.smile,
    takePhotoOnChallenge: LivenessDetectionStep.lookForward,
    backButtonText: 'Volver',
    userFaceFoundText: 'Rostro detectado',
    userFaceNotFoundText: 'Rostro no detectado',
    customizedLabel: LivenessDetectionLabelModel(
      blink: 'Step 1',
      lookUp: 'Step 2',
      lookDown: '',
      lookRight: 'Step 3',
      lookLeft: '',
      smile: 'Step 5',
      lookForward: 'Step 4 - Capture Here',
    ),
  );
  // Result: The photo is taken on lookForward, then the user still completes smile as the last challenge
}
