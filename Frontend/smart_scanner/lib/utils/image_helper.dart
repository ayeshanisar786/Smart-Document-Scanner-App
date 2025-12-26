import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'constants.dart';

// Image Processing Utilities
class ImageHelper {
  // Resize image to max dimensions
  static Future<File> resizeImage(
    File imageFile, {
    int maxWidth = AppConstants.maxImageWidth,
    int maxHeight = AppConstants.maxImageHeight,
  }) async {
    // Read image
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate new dimensions while maintaining aspect ratio
    int newWidth = image.width;
    int newHeight = image.height;

    if (newWidth > maxWidth || newHeight > maxHeight) {
      final aspectRatio = newWidth / newHeight;

      if (newWidth > newHeight) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }

      image = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Save resized image
    final tempDir = await getTemporaryDirectory();
    final resizedFile = File('${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await resizedFile.writeAsBytes(img.encodeJpg(image, quality: 85));

    return resizedFile;
  }

  // Create thumbnail
  static Future<File> createThumbnail(
    File imageFile, {
    int width = AppConstants.thumbnailWidth,
    int height = AppConstants.thumbnailHeight,
  }) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize maintaining aspect ratio
    final thumbnail = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    // Save thumbnail
    final tempDir = await getTemporaryDirectory();
    final thumbnailFile = File('${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 70));

    return thumbnailFile;
  }

  // Apply grayscale filter
  static Future<File> applyGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final grayscale = img.grayscale(image);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/gray_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(grayscale, quality: 85));

    return outputFile;
  }

  // Apply black and white filter
  static Future<File> applyBlackAndWhite(File imageFile, {int threshold = 128}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Convert to grayscale first
    final grayscale = img.grayscale(image);

    // Apply threshold for black and white
    for (int y = 0; y < grayscale.height; y++) {
      for (int x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final luminance = img.getLuminanceRgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        final newColor = luminance > threshold ? img.ColorRgb8(255, 255, 255) : img.ColorRgb8(0, 0, 0);
        grayscale.setPixel(x, y, newColor);
      }
    }

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/bw_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(grayscale, quality: 85));

    return outputFile;
  }

  // Adjust brightness
  static Future<File> adjustBrightness(File imageFile, int amount) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final adjusted = img.adjustColor(image, brightness: amount.toDouble());

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/bright_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(adjusted, quality: 85));

    return outputFile;
  }

  // Adjust contrast
  static Future<File> adjustContrast(File imageFile, double contrast) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final adjusted = img.contrast(image, contrast: contrast);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/contrast_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(adjusted, quality: 85));

    return outputFile;
  }

  // Auto enhance (brightness + contrast)
  static Future<File> autoEnhance(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Auto adjust brightness and contrast
    var enhanced = img.contrast(image, contrast: 110);
    enhanced = img.adjustColor(enhanced, brightness: 10);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(enhanced, quality: 90));

    return outputFile;
  }

  // Crop image
  static Future<File> cropImage(
    File imageFile, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(cropped, quality: 85));

    return outputFile;
  }

  // Rotate image
  static Future<File> rotateImage(File imageFile, int degrees) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final rotated = img.copyRotate(image, angle: degrees);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(rotated, quality: 85));

    return outputFile;
  }

  // Flip image horizontally
  static Future<File> flipHorizontal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final flipped = img.flipHorizontal(image);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/flipped_h_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(flipped, quality: 85));

    return outputFile;
  }

  // Flip image vertically
  static Future<File> flipVertical(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final flipped = img.flipVertical(image);

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/flipped_v_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(flipped, quality: 85));

    return outputFile;
  }

  // Get image dimensions
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    return {
      'width': image.width,
      'height': image.height,
    };
  }

  // Get file size
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  // Compress image to target size
  static Future<File> compressToSize(
    File imageFile, {
    int targetSizeBytes = 1024 * 1024, // 1MB default
  }) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Start with high quality and reduce until target size is reached
    int quality = 95;
    Uint8List? compressed;

    while (quality > 10) {
      compressed = Uint8List.fromList(img.encodeJpg(image, quality: quality));

      if (compressed.length <= targetSizeBytes) {
        break;
      }

      quality -= 5;
    }

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(compressed!);

    return outputFile;
  }

  // Convert to JPEG with specific quality
  static Future<File> convertToJpeg(File imageFile, {int quality = 85}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(img.encodeJpg(image, quality: quality));

    return outputFile;
  }

  // Check if file is an image
  static bool isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Get image from bytes
  static Future<File> saveImageFromBytes(
    Uint8List bytes, {
    String? filename,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final name = filename ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}
