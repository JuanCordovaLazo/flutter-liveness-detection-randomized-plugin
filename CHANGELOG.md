# 1.3.1 🚀

## New Features

- Added `faceLossGraceFrames` to configure face loss grace period (default: 3 frames)
- Added `frameProcessingInterval` to configure frame processing interval (default: 100ms)

## Improvements

- Made face loss detection timing and frame processing interval configurable for better control over detection sensitivity
- Updated all test files with new configuration parameters
- All tests passing with improved configuration coverage

---

# 1.3.0 🚀

## New Features

- Added `lookForward` as an optional challenge for final frontal face alignment before capture
- Added `lastChallenge` to pin any enabled challenge to the final position
- Added `mustShuffle` to control whether the effective challenge list is shuffled or preserved as declared
- Added `takePhotoOnChallenge` to decide which effective challenge triggers the photo capture
- Added `backButtonText`, `userFaceFoundText`, and `userFaceNotFoundText` for localized UI text customization
- Added `maxWidth` and `maxHeight` to constrain captured image output size while preserving aspect ratio
- Added `lookForward` to `LivenessDetectionLabelModel` for custom labeling of the forward-alignment step

## Improvements

- Centralized effective challenge list building for default and customized flows
- Final capture can now be decoupled from the final challenge through `takePhotoOnChallenge`
- Added post-capture image processing to resize and compress the output image when needed
- Optimized ML Kit face detection configuration and frame processing error handling
- Improved step overlay and circular progress animations with shorter, smoother transitions
- Expanded automated coverage with tests for challenge flow building, forward-face alignment, and image resizing

## Documentation

- Updated README and examples to document the new challenge flow controls, localized text options, and image resizing settings
- Expanded the example scenarios to cover the new flow configuration combinations

## Compatibility

- `shuffleListWithSmileLast` is now ignored; use `lastChallenge` to pin the final challenge explicitly

---

# 1.2.1 🚀

## Improvements

- ⬆️ **Kotlin updated to 2.1.0** for better performance and support 16KB google page size policy
- ⬆️ **compileSdk & targetSdk bumped to 36** (Android 16)
- ☕ **Java & Kotlin JVM target upgraded to VERSION_17**
- 📱 **minSdk raised to 24** (Android 7.0)
- 🗑️ **Removed `useLegacyPackaging`** — no longer needed with modern AGP
- 🔍 **google_mlkit_face_detection updated to 0.13.2** for improved face detection accuracy
- 🐦 **Flutter minimum version bumped to 3.38.7**

---

# 1.1.0 🚀

## BREAKING CHANGES

- 🔄 **API Refactor**: All parameters now consolidated into `LivenessDetectionConfig`
- 📦 **Simplified API**: `livenessDetection()` method now only requires `context` and `config`
- 🛠️ **Migration Required**: Update your implementation to use the new unified config approach

## New Features

- ⏱️ **NEW**: Automatic cooldown feature after 3 failed verification attempts. 10-minute waiting period with persistent countdown (survives app restarts). `enableCooldownOnFailure` parameter to control cooldown feature

## Bug Fixes

- 🛠️ **Fixed customizedLabel logic**: Corrected skip challenge behavior (empty string now properly skips)
- ✅ **Added validation**: `customizedLabel` must not be null when `useCustomizedLabel` is true
- 🔄 **Improved consistency**: Unified steps handling logic across the codebase

## Other Changes

- ✅ Moved `isEnableSnackBar` to config
- ✅ Moved `shuffleListWithSmileLast` to config
- ✅ Moved `showCurrentStep` to config
- ✅ Moved `isDarkMode` to config
- Update compile sdk and Gradle version for example & change deprecated .withOpacity(0.2) to .withAlpha(51) (Thanks to https://github.com/erikwibowo)

### Migration Guide:

**Before (v1.0.x):**

```dart
await plugin.livenessDetection(
  context: context,
  config: LivenessDetectionConfig(...),
  isEnableSnackBar: true,
  shuffleListWithSmileLast: true,
  showCurrentStep: true,
  isDarkMode: false,
);
```

**After (v1.1.0+):**

```dart
await plugin.livenessDetection(
  context: context,
  config: LivenessDetectionConfig(
    isEnableSnackBar: true,
    shuffleListWithSmileLast: true,
    showCurrentStep: true,
    isDarkMode: false,
    // ... other parameters
  ),
);
```

## 1.0.8 🚀

- 📦 Add packagingOptions with useLegacyPackaging for Android compatibility
- 🛠️ Fix InputImageConverterError for unsupported image formats
- 📷 Add configurable camera resolution preset (cameraResolution parameter)
- ⚡ Improved error handling for ML Kit face detection
- 🔧 Platform-specific image format optimization (NV21 for Android, BGRA8888 for iOS)

## 1.0.7 🚀

- ⚡ Update google_mlkit_face_detection for better compability to newest flutter version

## 1.0.6 🚀

- 🛠️ Fix issue camera preview freeze while start liveness detection
- 🎨 Face preview now looks better, no longer stretching
- 🎨 Add parameter to adjust image quality liveness result

## 1.0.5 🚀

- 🛠️ Improve security liveness challenge
- 🎨 Add set to max brightness option
- 🛠️ Update readme.md

## 1.0.4 🚀

- ⚡ Improved performance during liveness challenge verification
- 🎭 Customizable liveness challenge labels
- ⏳ Flexible security verification duration
- 🎲 Adjustable number of liveness challenges

## 1.0.3 🚀

- 🛠️ Adjust to compatible camera dependency to prevent face not found
- 🔐 Ajdust threshold for smile and look down challenge
- 🎨 Add showCurrentStep parameter (default : false)
- 🎨 Add Light and Dark mode

## 1.0.2 🚀

### Update README.md

- 🛠️ Update readme.md file

## 1.0.1 🚀

### Update dependencies 🛠️

- 🛠️ Update camera dependencies and also add camera_android_camerax for better experience while using liveness detection

## 1.0.0 🚀

### Introducing Flutter Liveness Detection Randomized Plugin!

✨ First Major Release Highlights:

- 🎯 Smart Liveness Detection System
- 🎲 Dynamic Random Challenge Generator
- 🔐 Enhanced Security Protocols
- 📱 Cross-Platform Support (iOS & Android)
- ⚡ Real-time Processing
- 🎨 Sleek & Modern UI
- 🛠️ Developer-Friendly Integration

Ready to revolutionize your biometric authentication? Let's make your app more secure! 💪
