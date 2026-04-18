import 'dart:math';

import 'package:image/image.dart' as img;

class LivenessImageTargetSize {
  final int width;
  final int height;

  const LivenessImageTargetSize({required this.width, required this.height});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LivenessImageTargetSize &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}

bool shouldPostProcessCapturedImage({
  required int quality,
  int? maxWidth,
  int? maxHeight,
}) {
  return quality < 95 || maxWidth != null || maxHeight != null;
}

LivenessImageTargetSize calculateTargetImageSize({
  required int width,
  required int height,
  int? maxWidth,
  int? maxHeight,
}) {
  assert(width > 0, 'width must be greater than 0');
  assert(height > 0, 'height must be greater than 0');

  if (maxWidth == null && maxHeight == null) {
    return LivenessImageTargetSize(width: width, height: height);
  }

  final double widthScale = maxWidth != null && width > maxWidth
      ? maxWidth / width
      : 1.0;
  final double heightScale = maxHeight != null && height > maxHeight
      ? maxHeight / height
      : 1.0;
  final double scale = min(1.0, min(widthScale, heightScale));

  if (scale >= 1.0) {
    return LivenessImageTargetSize(width: width, height: height);
  }

  return LivenessImageTargetSize(
    width: max(1, (width * scale).floor()),
    height: max(1, (height * scale).floor()),
  );
}

img.Image resizeImageIfNeeded({
  required img.Image image,
  int? maxWidth,
  int? maxHeight,
}) {
  final targetSize = calculateTargetImageSize(
    width: image.width,
    height: image.height,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );

  if (targetSize.width == image.width && targetSize.height == image.height) {
    return image;
  }

  return img.copyResize(
    image,
    width: targetSize.width,
    height: targetSize.height,
    interpolation: img.Interpolation.average,
  );
}
