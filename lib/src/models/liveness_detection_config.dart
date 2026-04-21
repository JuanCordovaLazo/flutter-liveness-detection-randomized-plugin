import 'package:camera/camera.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/core/enums/liveness_detection_step.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_label_model.dart';

class LivenessDetectionConfig {
  final bool startWithInfoScreen;
  final int? durationLivenessVerify;
  final bool showDurationUiText;
  final bool useCustomizedLabel;
  final LivenessDetectionLabelModel? customizedLabel;
  final bool isEnableMaxBrightness;
  final int imageQuality;
  final int? maxWidth;
  final int? maxHeight;
  final ResolutionPreset cameraResolution;
  final bool enableCooldownOnFailure;
  final int maxFailedAttempts;
  final int cooldownMinutes;
  final bool isEnableSnackBar;
  @Deprecated('Ignored. Use mustShuffle and lastChallenge instead.')
  final bool shuffleListWithSmileLast;
  final LivenessDetectionStep? lastChallenge;
  final LivenessDetectionStep? takePhotoOnChallenge;
  final bool? mustShuffle;
  final bool showCurrentStep;
  final bool isDarkMode;
  final String backButtonText;
  final String userFaceFoundText;
  final String userFaceNotFoundText;
  final int faceLossGraceFrames;
  final Duration frameProcessingInterval;

  LivenessDetectionConfig({
    this.startWithInfoScreen = false,
    this.durationLivenessVerify = 45,
    this.showDurationUiText = false,
    this.useCustomizedLabel = false,
    this.customizedLabel,
    this.isEnableMaxBrightness = true,
    this.imageQuality = 100,
    this.maxWidth,
    this.maxHeight,
    this.cameraResolution = ResolutionPreset.high,
    this.enableCooldownOnFailure = true,
    this.maxFailedAttempts = 3,
    this.cooldownMinutes = 10,
    this.isEnableSnackBar = true,
    @Deprecated('Ignored. Use mustShuffle and lastChallenge instead.')
    this.shuffleListWithSmileLast = false,
    this.lastChallenge,
    this.takePhotoOnChallenge,
    this.mustShuffle,
    this.showCurrentStep = false,
    this.isDarkMode = true,
    this.backButtonText = 'Back',
    this.userFaceFoundText = 'User Face Found',
    this.userFaceNotFoundText = 'User Face Not Found...',
    this.faceLossGraceFrames = 3,
    this.frameProcessingInterval = const Duration(milliseconds: 100),
  }) : assert(
         !useCustomizedLabel || customizedLabel != null,
         'customizedLabel must not be null when useCustomizedLabel is true',
       ),
       assert(
         maxWidth == null || maxWidth > 0,
         'maxWidth must be greater than 0',
       ),
       assert(
         maxHeight == null || maxHeight > 0,
         'maxHeight must be greater than 0',
       );
}
