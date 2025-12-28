import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'image_service.dart';

class LayerService {
  static Future<void> addSourceAndLayers(
    MapboxMap controller,
    String geoJson,
    String sourceBaseID,
  ) async {
    final String sourceID = '$sourceBaseID-source';
    final bool isPeak = sourceBaseID.contains('peak');

    // Add Image first so it's ready for the layers
    await addImageToStyle(controller, sourceBaseID);

    // Add Source
    if (!await controller.style.styleSourceExists(sourceID)) {
      await controller.style.addSource(
        GeoJsonSource(
          id: sourceID,
          data: geoJson,
          cluster: true,
          clusterMaxZoom: 16,
          clusterRadius: 50,
          clusterMinPoints: 2,
        ),
      );
    }

    // Cluster layer
    final String clusterLayerID = '$sourceBaseID-cluster';
    if (!await controller.style.styleLayerExists(clusterLayerID)) {
      await controller.style.addLayer(
        CircleLayer(
          id: clusterLayerID,
          sourceId: sourceID,
          filter: ["has", "point_count"],
          circleColor: isPeak
              ? Colors.black38.toARGB32()
              : Colors.blue.withValues(alpha: 0.6).toARGB32(),
          circleRadius: 20,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
      );
    }

    // Cluster count text
    final String countLayerID = '$sourceBaseID-count';
    if (!await controller.style.styleLayerExists(countLayerID)) {
      await controller.style.addLayer(
        SymbolLayer(
          id: countLayerID,
          sourceId: sourceID,
          filter: ["has", "point_count"],
          textColor: Colors.white.toARGB32(),
          textSize: 12.0,
          textIgnorePlacement: true,
          textAllowOverlap: true,
        ),
      );
      // Use setStyleLayerProperty for expression-based text field as SymbolLayer constructor only accepts String?
      await controller.style.setStyleLayerProperty(countLayerID, 'text-field', [
        "get",
        "point_count",
      ]);
    }

    // Individual Points Layer
    final String unclusteredLayerID = '$sourceBaseID-points';
    if (!await controller.style.styleLayerExists(unclusteredLayerID)) {
      await controller.style.addLayer(
        SymbolLayer(
          id: unclusteredLayerID,
          sourceId: sourceID,
          filter: [
            "!",
            ["has", "point_count"],
          ],
          iconImage: '$sourceBaseID-marker',
          textOffset: [0, 1.8],
          textColor: Colors.black.toARGB32(),
          textSize: 14.0,
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
        ),
      );

      // Set Dynamic Properties via expressions using setStyleLayerProperty

      // Icon Size changes when 'selected' feature state is true
      await controller.style.setStyleLayerProperty(
        unclusteredLayerID,
        'icon-size',
        [
          "case",
          [
            "boolean",
            ["feature-state", "selected"],
            false,
          ],
          1.8, // Selected size
          1.0, // Normal size
        ],
      );

      // Halo properties
      await controller.style.setStyleLayerProperty(
        unclusteredLayerID,
        'icon-halo-color',
        [
          "case",
          [
            "boolean",
            ["feature-state", "selected"],
            false,
          ],
          "#00B7FF",
          "rgba(0,0,0,0)",
        ],
      );

      await controller.style.setStyleLayerProperty(
        unclusteredLayerID,
        'icon-halo-width',
        [
          "case",
          [
            "boolean",
            ["feature-state", "selected"],
            false,
          ],
          2.5,
          0.0,
        ],
      );

      // Dynamic text field based on source type
      await controller.style.setStyleLayerProperty(
        unclusteredLayerID,
        'text-field',
        isPeak ? ["get", "name"] : ["get", "fna"],
      );
    }
  }

  static Future<void> addImageToStyle(
    MapboxMap controller,
    String sourceBaseID,
  ) async {
    final String imageName = '$sourceBaseID-marker';

    try {
      if (await controller.style.hasStyleImage(imageName)) return;

      // Ensure style is loaded before adding images
      int retryCount = 0;
      while (!await controller.style.isStyleLoaded() && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      final Uint8List imageBytes = await ImageService.loadImage(
        _getAssetPath(sourceBaseID),
      );

      await controller.style.addStyleImage(
        imageName,
        1.0,
        MbxImage(width: 24, height: 24, data: imageBytes),
        false,
        [],
        [],
        null,
      );

      log("✅ Image added to style: $imageName");
    } catch (e) {
      log("❌ Error adding image $imageName: $e");
    }
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
