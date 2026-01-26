import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

import 'image_service.dart';

class LayerService {
  static Future<void> addPlacesSource(MapboxMap mapboxMap) async {
    if (!await _ensureStyleIsLoaded(mapboxMap)) return;

    const String sourceID = 'places-source';
    const String layerID = 'places-layer';

    // 1. Fuente
    // Verificar si ya existe para evitar errores en Hot Reload
    if (!await mapboxMap.style.styleSourceExists(sourceID)) {
      await mapboxMap.style.addSource(
        VectorSource(
          id: sourceID,
          tiles: [MapConstants.placesMVT],
          minzoom: 5,
          maxzoom: 40,
        ),
      );
    }
    // En addPlacesSource

    // 2. Agregar Capa con lógica de Cluster
    await mapboxMap.style.addLayer(
      CircleLayer(
        id: "places-layer",
        sourceId: sourceID,
        sourceLayer: "places",
        // Radio variable: Si count > 1 (Cluster) es más grande
        circleRadiusExpression: [
          "case",
          [
            ">",
            ["get", "point_count"],
            1,
          ],
          18.0, // Radio Cluster
          6.0, // Radio Punto individual
        ],
        // Color variable: Naranja si es cluster, Azul si es punto (ejemplo)
        circleColorExpression: [
          "case",
          [
            ">",
            ["get", "point_count"],
            1,
          ],
          "#FF9800",
          "#467DFF",
        ],
        circleStrokeWidth: 2.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );

    // 3. (Opcional) Agregar Texto con el conteo
    await mapboxMap.style.addLayer(
      SymbolLayer(
        id: "places-count-layer",
        sourceId: sourceID,
        sourceLayer: "places",
        // Solo mostrar texto si es cluster
        filter: [">", "point_count", 1],
        textFieldExpression: [
          "to-string",
          ["get", "point_count"],
        ],
        textSize: 12.0,
        textColor: Colors.white.toARGB32(),
      ),
    );
  }

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
        tiles: [MapConstants.mountainAreasMVT], // Correcto: Lista de templates
        minzoom: 5, // Ajustado para que coincida con el zoom inicial de tu mapa
        maxzoom: 22,
      ),
    );

    await controller.style.addLayer(
      LineLayer(
        id: "debug-lines",
        sourceId: sourceId,
        sourceLayer: "mountain_areas_tiles",
        lineColor: Colors.black.toARGB32(), // Rojo fuerte
        lineWidth: .05, // Línea gruesa para verla fácil
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
        fillColor: Colors.blue.toARGB32(),
        // fillColor: Colors.green.toARGB32(),
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
