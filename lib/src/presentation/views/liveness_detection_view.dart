// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/core/constants/liveness_detection_step_constant.dart';
import 'package:collection/collection.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

List<CameraDescription> availableCams = [];

class LivenessDetectionView extends StatefulWidget {
  final LivenessDetectionConfig config;

  const LivenessDetectionView({super.key, required this.config});

  @override
  State<LivenessDetectionView> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionView> {
  static const int _faceLossGraceFrames = 3;

  // Camera related variables
  CameraController? _cameraController;
  int _cameraIndex = 0;
  bool _isBusy = false;
  bool _isTakingPicture = false;
  Timer? _timerToDetectFace;

  // Detection state variables
  late bool _isInfoStepCompleted;
  bool _isProcessingStep = false;
  bool _faceDetectedState = false;
  List<LivenessDetectionStepItem> _shuffledSteps = [];
  DateTime? _lookForwardHoldStartedAt;
  XFile? _capturedChallengeImage;
  int _faceLossFrameCount = 0;

  // Brightness Screen
  Future<void> setApplicationBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        brightness,
      );
    } catch (e) {
      throw 'Failed to set application brightness';
    }
  }

  Future<void> resetApplicationBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (e) {
      throw 'Failed to reset application brightness';
    }
  }

  // Steps related variables
  late final List<LivenessDetectionStepItem> steps;
  final GlobalKey<LivenessDetectionStepOverlayWidgetState> _stepsKey =
      GlobalKey<LivenessDetectionStepOverlayWidgetState>();

  Future<XFile?> _compressImage(XFile originalFile) async {
    final int quality = widget.config.imageQuality;

    if (quality >= 100) {
      return originalFile;
    }

    try {
      final bytes = await originalFile.readAsBytes();

      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        return originalFile;
      }

      final tempDir = await getTemporaryDirectory();
      final String targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedBytes = img.encodeJpg(originalImage, quality: quality);

      final File compressedFile = await File(
        targetPath,
      ).writeAsBytes(compressedBytes);

      return XFile(compressedFile.path);
    } catch (e) {
      debugPrint("Error compressing image: $e");
      return originalFile;
    }
  }

  @override
  void initState() {
    _preInitCallBack();
    super.initState();
    if (widget.config.enableCooldownOnFailure) {
      LivenessCooldownService.instance.configure(
        maxFailedAttempts: widget.config.maxFailedAttempts,
        cooldownMinutes: widget.config.cooldownMinutes,
      );
      LivenessCooldownService.instance.initializeCooldownTimer();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _postFrameCallBack());
  }

  @override
  void dispose() {
    _timerToDetectFace?.cancel();
    _timerToDetectFace = null;
    _cameraController?.dispose();

    if (widget.config.isEnableMaxBrightness) {
      resetApplicationBrightness();
    }
    super.dispose();
  }

  void _preInitCallBack() {
    _isInfoStepCompleted = !widget.config.startWithInfoScreen;
    _capturedChallengeImage = null;

    // Initialize and shuffle steps fresh each time
    _initializeShuffledSteps();

    if (widget.config.isEnableMaxBrightness) {
      setApplicationBrightness(1.0);
    }
  }

  void _postFrameCallBack() async {
    availableCams = await availableCameras();
    if (availableCams.any(
      (element) =>
          element.lensDirection == CameraLensDirection.front &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = availableCams.indexOf(
        availableCams.firstWhere(
          (element) =>
              element.lensDirection == CameraLensDirection.front &&
              element.sensorOrientation == 90,
        ),
      );
    } else {
      _cameraIndex = availableCams.indexOf(
        availableCams.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.front,
        ),
      );
    }
    if (!widget.config.startWithInfoScreen) {
      _startLiveFeed();
    }

    // Steps are shuffled fresh in _preInitCallBack
  }

  void _startLiveFeed() async {
    final camera = availableCams[_cameraIndex];
    _cameraController = CameraController(
      camera,
      widget.config.cameraResolution,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _cameraController?.initialize().then((_) {
      if (!mounted) return;
      _cameraController?.startImageStream(_processCameraImage);
      setState(() {});
    });
    _startFaceDetectionTimer();
  }

  void _startFaceDetectionTimer() {
    _timerToDetectFace = Timer(
      Duration(seconds: widget.config.durationLivenessVerify ?? 45),
      () => _onDetectionCompleted(imgToReturn: null),
    );
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    final camera = availableCams[_cameraIndex];
    final imageRotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (imageRotation == null) return;

    InputImage? inputImage;

    if (Platform.isAndroid) {
      if (cameraImage.format.group == ImageFormatGroup.nv21) {
        inputImage = InputImage.fromBytes(
          bytes: cameraImage.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(
              cameraImage.width.toDouble(),
              cameraImage.height.toDouble(),
            ),
            rotation: imageRotation,
            format: InputImageFormat.nv21,
            bytesPerRow: cameraImage.planes[0].bytesPerRow,
          ),
        );
      }
    } else if (Platform.isIOS) {
      if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        inputImage = InputImage.fromBytes(
          bytes: cameraImage.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(
              cameraImage.width.toDouble(),
              cameraImage.height.toDouble(),
            ),
            rotation: imageRotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: cameraImage.planes[0].bytesPerRow,
          ),
        );
      }
    }

    if (inputImage != null) {
      _processImage(inputImage);
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;

    final faces = await MachineLearningKitHelper.instance.processInputImage(
      inputImage,
    );

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      if (faces.isEmpty) {
        _resetLookForwardHold();
        _faceLossFrameCount++;
        final bool shouldReset =
            LivenessFaceOrientationHelper.hasExceededFaceLossGracePeriod(
              faceLossFrameCount: _faceLossFrameCount,
              gracePeriodFrames: _faceLossGraceFrames,
            );

        if (shouldReset) {
          _resetSteps();
          if (mounted) setState(() => _faceDetectedState = false);
        }
      } else {
        _faceLossFrameCount = 0;
        if (mounted) setState(() => _faceDetectedState = true);
        final currentIndex = _stepsKey.currentState?.currentIndex ?? 0;
        List<LivenessDetectionStepItem> currentSteps = _getStepsToUse();
        if (currentIndex < currentSteps.length) {
          _detectFace(face: faces.first, step: currentSteps[currentIndex].step);
        }
      }
    } else {
      _resetLookForwardHold();
      _resetSteps();
    }

    _isBusy = false;
    if (mounted) setState(() {});
  }

  void _detectFace({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    if (_isProcessingStep) return;

    debugPrint('Current Step: $step');

    switch (step) {
      case LivenessDetectionStep.blink:
        _resetLookForwardHold();
        await _handlingBlinkStep(face: face, step: step);
        break;

      case LivenessDetectionStep.lookRight:
        _resetLookForwardHold();
        await _handlingTurnRight(face: face, step: step);
        break;

      case LivenessDetectionStep.lookLeft:
        _resetLookForwardHold();
        await _handlingTurnLeft(face: face, step: step);
        break;

      case LivenessDetectionStep.lookUp:
        _resetLookForwardHold();
        await _handlingLookUp(face: face, step: step);
        break;

      case LivenessDetectionStep.lookDown:
        _resetLookForwardHold();
        await _handlingLookDown(face: face, step: step);
        break;

      case LivenessDetectionStep.smile:
        _resetLookForwardHold();
        await _handlingSmile(face: face, step: step);
        break;

      case LivenessDetectionStep.lookForward:
        await _handlingLookForward(face: face, step: step);
        break;
    }
  }

  Future<void> _completeStep({required LivenessDetectionStep step}) async {
    final bool shouldCaptureOnThisStep = _shouldCaptureOnThisStep(step);

    if (shouldCaptureOnThisStep) {
      await _takePicture(continueFlow: true);
    }

    if (mounted) setState(() {});
    await _stepsKey.currentState?.nextPage();

    _stopProcessing();
  }

  Future<void> _takePicture({bool continueFlow = false}) async {
    try {
      if (_cameraController == null || _isTakingPicture) return;

      if (mounted) setState(() => _isTakingPicture = true);
      await _cameraController?.stopImageStream();

      final XFile? clickedImage = await _cameraController?.takePicture();
      if (clickedImage == null) {
        if (continueFlow) {
          await _resumeImageStream();
        } else {
          _startLiveFeed();
        }
        if (mounted) setState(() => _isTakingPicture = false);
        return;
      }

      final XFile? finalImage = await _compressImage(clickedImage);

      debugPrint('Final image path: ${finalImage?.path}');

      if (continueFlow) {
        _capturedChallengeImage = finalImage;
        await _resumeImageStream();
        if (mounted) setState(() => _isTakingPicture = false);
        return;
      }

      _onDetectionCompleted(imgToReturn: finalImage);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) setState(() => _isTakingPicture = false);
      if (continueFlow) {
        await _resumeImageStream();
      } else {
        _startLiveFeed();
      }
    }
  }

  Future<void> _resumeImageStream() async {
    if (_cameraController == null) {
      return;
    }

    if (!_cameraController!.value.isInitialized) {
      return;
    }

    if (_cameraController!.value.isStreamingImages) {
      return;
    }

    await _cameraController?.startImageStream(_processCameraImage);
  }

  Future<void> _handleFlowCompleted() async {
    if (_capturedChallengeImage != null) {
      _onDetectionCompleted(imgToReturn: _capturedChallengeImage);
      return;
    }

    await _takePicture();
  }

  void _onDetectionCompleted({XFile? imgToReturn}) async {
    _timerToDetectFace?.cancel();
    _timerToDetectFace = null;

    final String? imgPath = imgToReturn?.path;

    if (imgPath != null) {
      final File imageFile = File(imgPath);
      final int fileSizeInBytes = await imageFile.length();
      final double sizeInKb = fileSizeInBytes / 1024;
      debugPrint('Image result size : ${sizeInKb.toStringAsFixed(2)} KB');
    }
    if (widget.config.isEnableSnackBar) {
      final snackBar = SnackBar(
        content: Text(
          imgToReturn == null
              ? 'Verification of liveness detection failed, please try again. (Exceeds time limit ${widget.config.durationLivenessVerify ?? 45} second.)'
              : 'Verification of liveness detection success!',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (!mounted) return;
    Navigator.of(context).pop(imgPath);
  }

  void _resetSteps() {
    List<LivenessDetectionStepItem> currentSteps = _getStepsToUse();
    _resetLookForwardHold();
    _capturedChallengeImage = null;
    _faceLossFrameCount = 0;

    for (var step in currentSteps) {
      final index = currentSteps.indexWhere((p1) => p1.step == step.step);
      if (index != -1) {
        currentSteps[index] = currentSteps[index].copyWith();
      }
    }

    if (_stepsKey.currentState?.currentIndex != 0) {
      _stepsKey.currentState?.reset();
    }

    if (mounted) setState(() {});
  }

  void _startProcessing() {
    if (!mounted) return;
    if (mounted) setState(() => _isProcessingStep = true);
  }

  void _stopProcessing() {
    if (!mounted) return;
    if (mounted) setState(() => _isProcessingStep = false);
  }

  /// Initialize and shuffle steps fresh each time
  void _initializeShuffledSteps() {
    _shuffledSteps = LivenessChallengeFlowBuilder.buildSteps(
      config: widget.config,
      defaultSteps: stepLiveness,
    );
  }

  /// Helper method to get the shuffled steps list
  List<LivenessDetectionStepItem> _getStepsToUse() {
    return _shuffledSteps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.config.isDarkMode ? Colors.black : Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _isInfoStepCompleted
            ? _buildDetectionBody()
            : LivenessDetectionTutorialScreen(
                duration: widget.config.durationLivenessVerify ?? 45,
                isDarkMode: widget.config.isDarkMode,
                onStartTap: () {
                  if (mounted) setState(() => _isInfoStepCompleted = true);
                  _startLiveFeed();
                },
              ),
      ],
    );
  }

  Widget _buildDetectionBody() {
    if (_cameraController == null ||
        _cameraController?.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: widget.config.isDarkMode ? Colors.black : Colors.white,
        ),
        LivenessDetectionStepOverlayWidget(
          cameraController: _cameraController,
          duration: widget.config.durationLivenessVerify,
          showDurationUiText: widget.config.showDurationUiText,
          isDarkMode: widget.config.isDarkMode,
          isFaceDetected: _faceDetectedState,
          backButtonText: widget.config.backButtonText,
          userFaceFoundText: widget.config.userFaceFoundText,
          userFaceNotFoundText: widget.config.userFaceNotFoundText,
          camera: CameraPreview(_cameraController!),
          key: _stepsKey,
          steps: _getStepsToUse(),
          showCurrentStep: widget.config.showCurrentStep,
          completionDelay: _getCompletionDelay(),
          onCompleted: _handleFlowCompleted,
        ),
      ],
    );
  }

  Duration _getCompletionDelay() {
    final LivenessDetectionStep? takePhotoOnChallenge =
        _getEffectiveTakePhotoOnChallenge();
    if (takePhotoOnChallenge == LivenessDetectionStep.lookForward) {
      return Duration.zero;
    }

    return const Duration(milliseconds: 500);
  }

  LivenessDetectionStep? _getEffectiveTakePhotoOnChallenge() {
    return LivenessChallengeFlowBuilder.resolveTakePhotoOnChallenge(
      config: widget.config,
      steps: _getStepsToUse(),
    );
  }

  bool _isLastEffectiveStep(LivenessDetectionStep step) {
    final List<LivenessDetectionStepItem> currentSteps = _getStepsToUse();
    return currentSteps.isNotEmpty && currentSteps.last.step == step;
  }

  bool _shouldCaptureOnThisStep(LivenessDetectionStep step) {
    final LivenessDetectionStep? takePhotoOnChallenge =
        _getEffectiveTakePhotoOnChallenge();
    return takePhotoOnChallenge == step && !_isLastEffectiveStep(step);
  }

  void _resetLookForwardHold() {
    _lookForwardHoldStartedAt = null;
  }

  double _getLookForwardAlignmentThreshold() {
    final headTurnThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdHead)
            as LivenessThresholdHead?;
    final double rotationAngle = headTurnThreshold?.rotationAngle ?? 45.0;

    return min(15.0, max(8.0, rotationAngle / 3));
  }

  double _getSideTurnThreshold() {
    final headTurnThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdHead)
            as LivenessThresholdHead?;
    final double rotationAngle = headTurnThreshold?.rotationAngle ?? 45.0;

    return min(20.0, max(14.0, rotationAngle / 2.5));
  }

  Future<void> _handlingBlinkStep({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final blinkThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdBlink)
            as LivenessThresholdBlink?;

    if ((face.leftEyeOpenProbability ?? 1.0) <
            (blinkThreshold?.leftEyeProbability ?? 0.25) &&
        (face.rightEyeOpenProbability ?? 1.0) <
            (blinkThreshold?.rightEyeProbability ?? 0.25)) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingTurnRight({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final bool isTurnedRight =
        LivenessFaceOrientationHelper.isHeadTurnedForStep(
          step: step,
          headEulerAngleY: face.headEulerAngleY,
          minYawThreshold: _getSideTurnThreshold(),
          isIOS: Platform.isIOS,
        );

    if (isTurnedRight) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingTurnLeft({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final bool isTurnedLeft = LivenessFaceOrientationHelper.isHeadTurnedForStep(
      step: step,
      headEulerAngleY: face.headEulerAngleY,
      minYawThreshold: _getSideTurnThreshold(),
      isIOS: Platform.isIOS,
    );

    if (isTurnedLeft) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingLookUp({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final headTurnThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdHead)
            as LivenessThresholdHead?;
    if ((face.headEulerAngleX ?? 0) >
        (headTurnThreshold?.rotationAngle ?? 20)) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingLookDown({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final headTurnThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdHead)
            as LivenessThresholdHead?;
    if ((face.headEulerAngleX ?? 0) <
        (headTurnThreshold?.rotationAngle ?? -15)) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingSmile({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final smileThreshold =
        FlutterLivenessDetectionRandomizedPlugin.instance.thresholdConfig
                .firstWhereOrNull((p0) => p0 is LivenessThresholdSmile)
            as LivenessThresholdSmile?;

    if ((face.smilingProbability ?? 0) >
        (smileThreshold?.probability ?? 0.65)) {
      _startProcessing();
      await _completeStep(step: step);
    }
  }

  Future<void> _handlingLookForward({
    required Face face,
    required LivenessDetectionStep step,
  }) async {
    final DateTime now = DateTime.now();
    final double alignmentThreshold = _getLookForwardAlignmentThreshold();
    final bool isFacingForward =
        LivenessFaceOrientationHelper.isFaceAlignedForStep(
          step: step,
          face: face,
          maxPitch: alignmentThreshold,
          maxYaw: alignmentThreshold,
        );

    if (!isFacingForward) {
      _resetLookForwardHold();
      return;
    }

    _lookForwardHoldStartedAt ??= now;

    if (!LivenessFaceOrientationHelper.hasSatisfiedLookForwardHold(
      startedAt: _lookForwardHoldStartedAt!,
      now: now,
    )) {
      return;
    }

    _resetLookForwardHold();
    _startProcessing();
    await _completeStep(step: step);
  }
}
