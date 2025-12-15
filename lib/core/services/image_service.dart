import 'dart:ui';

import 'package:flutter/services.dart';
export 'package:peak_trail/utils/app_assets.dart';

class ImageService {
  static Future<Uint8List> loadImage(String imagePath) async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageData = bytes.buffer.asUint8List();
    return imageData;
  }

  static Future<Uint8List> resizeImage(
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

    return byteData!.buffer.asUint8List();
  }
}
