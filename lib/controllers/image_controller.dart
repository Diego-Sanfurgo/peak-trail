import 'package:flutter/services.dart';
export 'package:peak_trail/utils/app_assets.dart';

class ImageController {
  static Future<Uint8List> loadImage(String imagePath) async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageData = bytes.buffer.asUint8List();
    return imageData;
  }
}
