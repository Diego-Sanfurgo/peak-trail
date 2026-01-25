import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

import 'image_service.dart';

class LayerService {
  static Future<void> addPointLayers(
    MapboxMap controller,
    String geoJson,
    String sourceBaseID,
  ) async {
    final String sourceID = '$sourceBaseID-source';
    final bool isPeak = sourceBaseID.contains('peak');
    final bool isPass = sourceBaseID.contains('pass');
    final bool isWaterfall = sourceBaseID.contains('waterfall');
    // Add Image first so it's ready for the layers
    await addImageToStyle(controller, sourceBaseID);

    final int circleClusterColor = switch (true) {
      _ when isPeak => Colors.black38.toARGB32(),
      _ when isPass => Colors.green.withValues(alpha: 0.6).toARGB32(),
      _ when isWaterfall => Colors.purple.withValues(alpha: 0.6).toARGB32(),
      _ => Colors.black38.toARGB32(),
    };

    // Add Source
    if (!await controller.style.styleSourceExists(sourceID)) {
      await controller.style.addSource(
        GeoJsonSource(
          id: sourceID,
          data: geoJson,
          cluster: true,
          clusterMaxZoom: 16,
          clusterRadius: 100,
          clusterMinPoints: 4,
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
          circleColor: circleClusterColor,
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
          iconSize: 0.4,
          iconHaloColor: Colors.white.toARGB32(),
          iconHaloWidth: 2,
          textOffset: [0, 3],
          textColor: Colors.black.toARGB32(),
          textSize: 14.0,
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconSizeExpression: [
            "case",
            [
              "boolean",
              ["feature-state", "selected"],
              false,
            ],
            2.5, // Selected size
            1.0, // Normal size
          ],
        ),
      );

      // Dynamic text field based on source type
      await controller.style.setStyleLayerProperty(
        unclusteredLayerID,
        'text-field',
        [
          "concat",
          isPeak ? ["get", "name"] : ["get", "fna"],
          "\n",
          ["get", "alt"],
        ],
      );
    }
  }

  static Future<void> addPolygonLayers(
    MapboxMap controller,
    String geoJson,
    String sourceBaseID,
  ) async {
    final String sourceID = '$sourceBaseID-source';

    if (!await _ensureStyleIsLoaded(controller)) return;

    // Add Source
    if (!await controller.style.styleSourceExists(sourceID)) {
      await controller.style.addSource(
        GeoJsonSource(id: sourceID, data: geoJson, cluster: false),
      );
    }

    // Fill Layer
    final String fillLayerID = '$sourceBaseID-fill';
    if (!await controller.style.styleLayerExists(fillLayerID)) {
      await controller.style.addLayer(
        FillLayer(
          id: fillLayerID,
          sourceId: sourceID,
          fillColor: Colors.blue.withValues(alpha: 0.3).toARGB32(),
          fillOutlineColor: Colors.blue.withValues(alpha: 0.8).toARGB32(),
        ),
      );
    }

    // Line Layer
    final String lineLayerID = '$sourceBaseID-line';
    if (!await controller.style.styleLayerExists(lineLayerID)) {
      await controller.style.addLayer(
        LineLayer(
          id: lineLayerID,
          sourceId: sourceID,
          lineColor: Colors.blue.toARGB32(),
          lineWidth: 1.5,
        ),
      );
    }
  }

  static Future<void> addTrackingLayer(
    MapboxMap controller,
    String geoJson,
    String sourceBaseID,
  ) async {
    final String sourceID = '$sourceBaseID-source';

    if (!await _ensureStyleIsLoaded(controller)) return;

    // Add Source
    if (!await controller.style.styleSourceExists(sourceID)) {
      await controller.style.addSource(
        GeoJsonSource(id: sourceID, data: geoJson, cluster: false),
      );
    }

    // Line Layer
    final String lineLayerID = '$sourceBaseID-line';
    if (!await controller.style.styleLayerExists(lineLayerID)) {
      // 2. Crear la capa de línea conectada a esa fuente
      final LineLayer layer = LineLayer(
        id: lineLayerID,
        sourceId: sourceID,
        lineWidth: 5.0,
        lineColor: Colors.orange.toARGB32(), // O el color hexadecimal en int
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      );
      await controller.style.addLayer(layer);
    }
  }

  static Future<void> addImageToStyle(
    MapboxMap controller,
    String sourceBaseID,
  ) async {
    final String imageName = '$sourceBaseID-marker';

    try {
      if (await controller.style.hasStyleImage(imageName)) return;

      // // Ensure style is loaded before adding images
      if (!await _ensureStyleIsLoaded(controller)) return;

      final SizedImage imageBytes = await ImageService.loadSizedImage(
        _getAssetPath(sourceBaseID),
      );

      await controller.style.addStyleImage(
        imageName,
        1,
        MbxImage(
          width: imageBytes.width,
          height: imageBytes.height,
          data: imageBytes.data,
        ),
        true,
        [],
        [],
        null,
      );

      log("✅ Image added to style: $imageName");
    } catch (e) {
      log("❌ Error adding image $imageName: $e");
    }
  }

  static Future<void> addMountainAreaAll(MapboxMap controller) async {
    // Asegúrate que tu URL termina exactamente así en MapConstants:
    // ".../mvt-mountains/{z}/{x}/{y}" (sin parámetros extra si usas --no-verify-jwt)

    const String sourceId = "mountains-mvt-source";
    const String layerId = "mountains-fill-layer";

    // 1. Añadir Fuente (Corrigiendo 'url' por 'tiles')
    await controller.style.addSource(
      VectorSource(
        id: sourceId,
        tiles: [
          MapConstants.mountainAreaSourceURL,
        ], // Correcto: Lista de templates
        minzoom: 5, // Ajustado para que coincida con el zoom inicial de tu mapa
        maxzoom: 22,
      ),
    );

    // Elimina el CircleLayer y añade esto temporalmente:
    await controller.style.addLayer(
      LineLayer(
        id: "debug-lines",
        sourceId: sourceId,
        sourceLayer: "mountain_areas_tiles",
        lineColor: Colors.red.toARGB32(), // Rojo fuerte
        lineWidth: 3.0, // Línea gruesa para verla fácil
        lineOpacity: 1.0,
      ),
    );

    // 2. Añadir Capa
    await controller.style.addLayer(
      FillLayer(
        id: layerId,
        sourceId: sourceId,
        sourceLayer:
            "mountain_areas_tiles", // Debe coincidir con el string en tu SQL ST_AsMVT
        fillColor: Colors.green
            .toARGB32(), // Mapbox Flutter v2 usa int (ARGB) estándar
        fillOpacity: 0.4,
        fillOutlineColor: Colors.green[900]!.toARGB32(),
      ),
    );
  }
}

String _getAssetPath(String sourceBaseID) {
  switch (sourceBaseID) {
    case 'waterfall':
      return AppAssets.WATERFALL_PIN;
    case 'peak':
      return AppAssets.MOUNTAIN_PIN;
    case 'pass':
      return AppAssets.MOUNTAIN_PASS_PIN;
    case 'lake':
      return AppAssets.VOLCANO_PIN;
    default:
      throw ArgumentError('Unsupported sourceBaseID: $sourceBaseID');
  }
}

// Ensure style is loaded
Future<bool> _ensureStyleIsLoaded(MapboxMap controller) async {
  int retryCount = 0;
  while (!await controller.style.isStyleLoaded() && retryCount < 10) {
    await Future.delayed(const Duration(milliseconds: 200));
    retryCount++;
  }
  return retryCount < 10;
}
