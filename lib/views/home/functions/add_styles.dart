import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/controllers/image_controller.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';

Future<void> addStyles(MapboxMap controller) async {
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

    final image = await ImageController.loadImage(AppAssets.mountainIcon24);
    // final img = await decodeImageFromList(image);

    await Future.delayed(const Duration(milliseconds: 500));
    controller.style.addStyleImage(
      MapConstants.mountainMarkerId,
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
