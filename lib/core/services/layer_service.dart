import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

import 'image_service.dart';

class LayerService {
  static Future<void> addPlacesSource(MapboxMap mapboxMap) async {
    if (!await _ensureStyleIsLoaded(mapboxMap)) return;

    const String sourceID = 'places-source';

    // 1. Cargar imágenes para cada tipo de punto
    const List<String> placeTypes = ['lake', 'pass', 'peak', 'waterfall'];
    for (final String type in placeTypes) {
      await addPlaceImageToStyle(mapboxMap, type);
    }

    // 2. Fuente
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

    const String clusterLayerID = 'places-cluster';
    const String countLayerID = 'places-count';
    const String pointsLayerID = 'places-points';

    // 3. Agregar Capa con lógica de Cluster
    if (!await mapboxMap.style.styleLayerExists(clusterLayerID)) {
      await mapboxMap.style.addLayer(
        CircleLayer(
          id: clusterLayerID,
          sourceId: sourceID,
          sourceLayer: "places",
          filter: [
            ">",
            ["get", "point_count"],
            1,
          ],
          circleRadius: 18.0,
          circleColor: Colors.orange.toARGB32(),
          circleStrokeWidth: 2.0,
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    }

    // 4. Agregar Texto con el conteo del cluster
    if (!await mapboxMap.style.styleLayerExists(countLayerID)) {
      await mapboxMap.style.addLayer(
        SymbolLayer(
          id: countLayerID,
          sourceId: sourceID,
          sourceLayer: "places",
          filter: [
            ">",
            ["get", "point_count"],
            1,
          ],
          textFieldExpression: [
            "to-string",
            ["get", "point_count"],
          ],
          textSize: 12.0,
          textColor: Colors.white.toARGB32(),
          textIgnorePlacement: true,
          textAllowOverlap: true,
        ),
      );
    }

    // 5. Agregar SymbolLayer para puntos individuales
    if (!await mapboxMap.style.styleLayerExists(pointsLayerID)) {
      await mapboxMap.style.addLayer(
        SymbolLayer(
          id: pointsLayerID,
          sourceId: sourceID,
          sourceLayer: "places",
          // Filtro inverso al cluster: muestra puntos donde point_count NO es > 1
          filter: [
            "!",
            [
              ">",
              [
                "coalesce",
                ["get", "point_count"],
                0,
              ],
              1,
            ],
          ],
          // Icono dinámico basado en el tipo de punto
          iconImageExpression: [
            "concat",
            ["get", "type"],
            "-marker",
          ],
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
          // feature-state:selected para gestionar interacciones
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

      // Texto dinámico: nombre + altura (si existe)
      await mapboxMap.style.setStyleLayerProperty(pointsLayerID, 'text-field', [
        "case",
        ["has", "alt"],
        [
          "concat",
          ["get", "name"],
          "\n",
          ["get", "alt"],
          "m",
        ],
        ["get", "name"],
      ]);
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

  /// Carga una imagen para un tipo de lugar específico (lake, pass, peak, waterfall)
  static Future<void> addPlaceImageToStyle(
    MapboxMap controller,
    String placeType,
  ) async {
    final String imageName = '$placeType-marker';

    try {
      if (await controller.style.hasStyleImage(imageName)) return;

      if (!await _ensureStyleIsLoaded(controller)) return;

      final SizedImage imageBytes = await ImageService.loadSizedImage(
        _getAssetPath(placeType),
      );

      await controller.style.addStyleImage(
        imageName,
        1.2,
        MbxImage(
          width: imageBytes.width,
          height: imageBytes.height,
          data: imageBytes.data,
        ),
        false,
        [],
        [],
        null,
      );

      log("✅ Place image added to style: $imageName");
    } catch (e) {
      log("❌ Error adding place image $imageName: $e");
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
      return AppAssets.PEAK_PIN;
    case 'pass':
      return AppAssets.BRIDGE_PIN;
    case 'lake':
      return AppAssets.LAKE_PIN;
    case 'park':
      return AppAssets.PARK_PIN;
    case 'volcano':
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
