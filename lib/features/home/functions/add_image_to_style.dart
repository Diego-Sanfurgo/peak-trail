import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/services/image_service.dart';

Future<void> addImageToStyle(MapboxMap controller, String sourceBaseID) async {
  try {
    // 🔹 Esperar a que el estilo esté listo del todo
    bool isReady = false;
    for (int i = 0; i < 10; i++) {
      if (await controller.style.isStyleLoaded()) {
        isReady = true;
        break;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!isReady) {
      log("❌ El estilo no terminó de cargarse");
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final image = await ImageService.loadImage(_getAssetPath(sourceBaseID));
    // final img = await decodeImageFromList(image);

    await Future.delayed(const Duration(milliseconds: 500));
    controller.style.addStyleImage(
      '$sourceBaseID-marker',
      1,
      MbxImage(
        width: 24,
        // width: img.width,
        height: 24,
        // height: img.height,
        data: image,
      ),
      false,
      [],
      [],
      null,
    );
  } on Exception catch (e) {
    log("❌ Error al agregar imagen: $e");
  }
}

String _getAssetPath(String sourceBaseID) {
  switch (sourceBaseID) {
    case 'waterfall':
      return AppAssets.WATERFALL_24;
    case 'peak':
      return AppAssets.LANDSCAPE_24;
    default:
      throw ArgumentError('Unsupported sourceBaseID: $sourceBaseID');
  }
}
