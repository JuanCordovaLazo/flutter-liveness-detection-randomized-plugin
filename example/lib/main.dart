import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
  );
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String?> capturedImages = [];
  String? imgPath;
  int livenessScenario = 0;
  final int totalScenarios = 12;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          children: [
            if (imgPath != null) ...[
              const Text(
                'Result Liveness Detection',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Align(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(imgPath!), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Liveness Scenario ${livenessScenario + 1}/$totalScenarios',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getScenarioDescription(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () async {
                final config = _getTestConfig();
                final String? response =
                    await FlutterLivenessDetectionRandomizedPlugin.instance
                        .livenessDetection(context: context, config: config);
                if (mounted) {
                  setState(() {
                    imgPath = response;
                  });
                }
              },
              label: const Text('Start Liveness Detection'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  livenessScenario = (livenessScenario + 1) % totalScenarios;
                });
              },
              child: const Text('Next Liveness Scenario'),
            ),
          ],
        ),
      ),
    );
  }

  String _getScenarioDescription() {
    switch (livenessScenario) {
      case 0:
        return 'Default: Smile always last + Info screen';
      case 1:
        return 'Random shuffle: No smile priority';
      case 2:
        return 'Dark mode + High resolution + No info';
      case 3:
        return 'Custom labels: All steps with Indonesian';
      case 4:
        return 'Skip steps: Only 3 challenges (blink, smile, lookUp)';
      case 5:
        return 'Low quality + Duration timer + Cooldown enabled';
      case 6:
        return 'Max brightness off + No snackbar + Hide steps';
      case 7:
        return 'All features: Custom + Timer + Cooldown + Dark';
      case 8:
        return 'Custom order: mustShuffle false keeps declared order';
      case 9:
        return 'Custom shuffle: smile forced to the last step';
      case 10:
        return 'Custom shuffle: lookForward forced last for frontal capture';
      case 11:
        return 'Legacy compatibility: shuffleListWithSmileLast still works';
      default:
        return '';
    }
  }

  LivenessDetectionConfig _getTestConfig() {
    switch (livenessScenario) {
      case 0: // Default scenario
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 100,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          showDurationUiText: false,
          startWithInfoScreen: true,
          useCustomizedLabel: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          lastChallenge: LivenessDetectionStep.smile,
          isDarkMode: false,
          showCurrentStep: true,
        );
      case 1: // Random shuffle
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 85,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 30,
          showDurationUiText: false,
          startWithInfoScreen: false,
          useCustomizedLabel: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          mustShuffle: true,
          isDarkMode: false,
          showCurrentStep: true,
        );
      case 2: // Dark mode + High res
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.high,
          imageQuality: 100,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 60,
          showDurationUiText: false,
          startWithInfoScreen: false,
          useCustomizedLabel: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          lastChallenge: LivenessDetectionStep.smile,
          isDarkMode: true,
          showCurrentStep: true,
        );
      case 3: // Custom labels Indonesian
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 90,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          showDurationUiText: false,
          startWithInfoScreen: true,
          useCustomizedLabel: true,
          mustShuffle: true,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          lastChallenge: LivenessDetectionStep.smile,
          isDarkMode: false,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Kedip 2-3 Kali',
            lookDown: 'Lihat ke Bawah',
            lookRight: 'Lihat ke Kanan',
            lookLeft: 'Lihat ke Kiri',
            lookUp: 'Lihat ke Atas',
            smile: 'Tersenyum Lebar',
          ),
        );
      case 4: // Skip some steps
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.low,
          imageQuality: 70,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 30,
          showDurationUiText: false,
          startWithInfoScreen: false,
          useCustomizedLabel: true,
          mustShuffle: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          isDarkMode: false,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink Eyes',
            lookDown: '', // Skip
            lookLeft: '', // Skip
            lookRight: '', // Skip
            lookUp: 'Look Up Please',
            smile: 'Smile Wide',
          ),
        );
      case 5: // Low quality + Timer + Cooldown
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.low,
          imageQuality: 50,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 20,
          showDurationUiText: true,
          startWithInfoScreen: true,
          useCustomizedLabel: false,
          enableCooldownOnFailure: true,
          maxFailedAttempts: 2,
          cooldownMinutes: 5,
          isEnableSnackBar: true,
          lastChallenge: LivenessDetectionStep.smile,
          isDarkMode: false,
          showCurrentStep: true,
        );
      case 6: // Minimal features
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 80,
          isEnableMaxBrightness: false,
          durationLivenessVerify: 40,
          showDurationUiText: false,
          startWithInfoScreen: false,
          useCustomizedLabel: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: false,
          mustShuffle: true,
          isDarkMode: false,
          showCurrentStep: false,
        );
      case 7: // All features enabled
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.high,
          imageQuality: 95,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 50,
          showDurationUiText: true,
          startWithInfoScreen: true,
          useCustomizedLabel: true,
          enableCooldownOnFailure: true,
          maxFailedAttempts: 3,
          cooldownMinutes: 10,
          isEnableSnackBar: true,
          mustShuffle: true,
          lastChallenge: LivenessDetectionStep.smile,
          isDarkMode: true,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: '👁️ Kedipkan Mata',
            lookDown: '⬇️ Lihat Bawah',
            lookRight: '➡️ Lihat Kanan',
            lookLeft: '⬅️ Lihat Kiri',
            lookUp: '⬆️ Lihat Atas',
            smile: '😊 Senyum Manis',
          ),
        );
      case 8: // Explicit order without shuffle
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 90,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          startWithInfoScreen: true,
          useCustomizedLabel: true,
          mustShuffle: false,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          isDarkMode: false,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Step 1: Blink',
            lookUp: 'Step 2: Look Up',
            lookDown: '',
            lookRight: 'Step 3: Turn Right',
            lookLeft: '',
            smile: 'Step 4: Smile',
            lookForward: 'Step 5: Face Forward',
          ),
        );
      case 9: // Shuffle with smile last
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 90,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          startWithInfoScreen: true,
          useCustomizedLabel: true,
          mustShuffle: true,
          lastChallenge: LivenessDetectionStep.smile,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          isDarkMode: false,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink',
            lookUp: 'Look Up',
            lookDown: 'Look Down',
            lookRight: 'Look Right',
            lookLeft: 'Look Left',
            smile: 'Smile Last',
          ),
        );
      case 10: // Shuffle with lookForward last
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 90,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          startWithInfoScreen: true,
          useCustomizedLabel: true,
          mustShuffle: true,
          lastChallenge: LivenessDetectionStep.lookForward,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          isDarkMode: false,
          showCurrentStep: true,
          customizedLabel: LivenessDetectionLabelModel(
            blink: 'Blink',
            lookUp: 'Look Up',
            lookDown: 'Look Down',
            lookRight: 'Look Right',
            lookLeft: 'Look Left',
            smile: 'Smile',
            lookForward: 'Face Forward For Capture',
          ),
        );
      case 11: // Legacy compatibility
        return LivenessDetectionConfig(
          cameraResolution: ResolutionPreset.medium,
          imageQuality: 90,
          isEnableMaxBrightness: true,
          durationLivenessVerify: 45,
          startWithInfoScreen: true,
          useCustomizedLabel: false,
          mustShuffle: true,
          enableCooldownOnFailure: false,
          isEnableSnackBar: true,
          // ignore: deprecated_member_use
          shuffleListWithSmileLast: true,
          isDarkMode: false,
          showCurrentStep: true,
        );
      default:
        return LivenessDetectionConfig();
    }
  }
}
