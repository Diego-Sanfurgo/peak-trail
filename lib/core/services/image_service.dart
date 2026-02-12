import 'dart:ui';

import 'package:flutter/services.dart';
export 'package:saltamontes/core/theme/app_assets.dart';

class ImageService {
  static Future<Uint8List> loadImage(String imagePath) async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageData = bytes.buffer.asUint8List();
    return imageData;
  }

  static Future<SizedImage> loadSizedImage(String imagePath) async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageData = bytes.buffer.asUint8List();
    final Codec codec = await instantiateImageCodec(imageData);
    final FrameInfo frame = await codec.getNextFrame();
    final Image image = frame.image;
    return SizedImage(
      data: imageData,
      width: image.width,
      height: image.height,
    );
  }

  static Future<SizedImage> resizeImage(
    Uint8List data,
    int targetWidth,
    int targetHeight,
  ) async {
    // Decodificar imagen original
    final Codec codec = await instantiateImageCodec(
      data,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final FrameInfo frame = await codec.getNextFrame();

    // Convertir a bytes RGBA
    final Image resized = frame.image;
    final ByteData? byteData = await resized.toByteData(
      format: ImageByteFormat.rawRgba,
    );

    return SizedImage(
      data: byteData!.buffer.asUint8List(),
      width: resized.width,
      height: resized.height,
    );
  }
}

class SizedImage {
  final Uint8List data;
  final int width;
  final int height;

  const SizedImage({
    required this.data,
    required this.width,
    required this.height,
  });
}
