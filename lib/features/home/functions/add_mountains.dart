import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/data/models/cluster_feature.dart';
import 'package:peak_trail/data/models/mountain.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
import 'package:peak_trail/features/home/functions/add_styles.dart';

Future<void> addMountainsLayers(MapboxMap controller, String geoJson) async {
  await controller.style.addSource(
    GeoJsonSource(
      id: MapConstants.mountainsSourceId,
      data: geoJson,
      cluster: true,
      clusterMaxZoom: 16,
      clusterRadius: 50,
      clusterMinPoints: 2,
    ),
  );

  //Cluster layer
  await controller.style.addLayer(
    CircleLayer(
      id: MapConstants.clusterLayerId,
      sourceId: MapConstants.mountainsSourceId,
      circleColor: Colors.grey.toARGB32(),
      circleRadius: 20,
      filter: ["has", "point_count"],
      circleStrokeColor: Colors.white.toARGB32(),
      circleStrokeWidth: 2,
    ),
  );

  // Texto del cluster
  // 🔢 Texto con el número de puntos
  await controller.style.addLayer(
    SymbolLayer(
      id: MapConstants.clusterCountId,
      sourceId: MapConstants.mountainsSourceId,
      filter: ["has", "point_count"],
      textFieldExpression: ["get", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textIgnorePlacement: true,
      textAllowOverlap: true,
    ),
  );

  await addStyles(controller);
  if (!await controller.style.hasStyleImage(MapConstants.mountainMarkerId)) {
    await addStyles(controller);
  }

  // Puntos individuales
  await controller.style.addLayer(
    SymbolLayer(
      id: MapConstants.singlePointId,
      sourceId: MapConstants.mountainsSourceId,
      filter: [
        "!",
        ["has", "point_count"],
      ],
      iconImage: MapConstants.mountainMarkerId,
      iconSizeExpression: [
        "case",
        [
          "boolean",
          ["feature-state", "selected"],
          false,
        ],
        1.8, // tamaño cuando está seleccionado
        1.0, // tamaño normal
      ],
      iconHaloColorExpression: [
        "case",
        [
          "boolean",
          ["feature-state", "selected"],
          false,
        ],
        "#00B7FF", // Glow celeste
        "rgba(0,0,0,0)", // Sin halo
      ],
      iconHaloWidthExpression: [
        "case",
        [
          "boolean",
          ["feature-state", "selected"],
          false,
        ],
        2.5,
        0.0,
      ],
      iconOpacityExpression: [
        "case",
        ["has", "point_count"], // si es cluster
        0.0, // no mostrar ícono
        1.0, // mostrarlo normalmente
      ],

      textFieldExpression: ["get", "name"],
      // textFieldExpression: ["get", "fna"],
      iconSize: 1,
      textOffset: [0, 1.8],
      textColor: Colors.black.toARGB32(),
      textSize: 14.0,
      textHaloColor: Colors.white.toARGB32(),
      textHaloWidth: 1.5,
    ),
  );

  // La capa de puntos individuales debe ir POR ENCIMA de los clusters
  await controller.style.moveStyleLayer(
    MapConstants.singlePointId,
    LayerPosition(above: "cluster-count"),
  );

  await _addOnTapListener(controller);
}

Future<void> _addOnTapListener(MapboxMap controller) async {
  controller.setOnMapTapListener((MapContentGestureContext mapContext) async {
    final List<QueriedRenderedFeature?> features = await controller
        .queryRenderedFeatures(
          RenderedQueryGeometry.fromScreenCoordinate(mapContext.touchPosition),
          RenderedQueryOptions(
            layerIds: [MapConstants.clusterLayerId, MapConstants.singlePointId],
            filter: null,
          ),
        );

    if (features.isEmpty) return;

    final QueriedRenderedFeature? feature = features.first;
    final rawFeature = feature!.queriedFeature.feature;
    if (feature.layers.contains(MapConstants.singlePointId)) {
      final Mountain mountain = Mountain.fromFeature(rawFeature);

      // Des-seleccionar anterior
      // if (_selectedFeatureId != null) {
      //   await controller.setFeatureState(
      //     AppConstants.mountainsSourceId,
      //     _selectedFeatureId!,
      //     {"selected": false},
      //   );
      // }

      // Seleccionar nuevo
      await controller.setFeatureState(
        MapConstants.mountainsSourceId,
        null,
        mountain.id,
        jsonEncode({"selected": true}),
      );

      // _selectedFeatureId = featureId;

      final point = Point.fromJson(mountain.coordinates.toJson());
      await controller.easeTo(
        CameraOptions(center: point, zoom: 14.5),
        MapAnimationOptions(duration: 500),
      );
    }
    if (feature.layers.contains(MapConstants.clusterLayerId)) {
      final ClusterFeature clusterFeature = ClusterFeature.fromFeature(
        rawFeature,
      );

      // Calcular el nuevo zoom ideal para expandir este clúster
      final FeatureExtensionValue zoom = await controller
          .getGeoJsonClusterExpansionZoom(
            MapConstants.mountainsSourceId,
            clusterFeature.toJson(),
          );

      final point = Point.fromJson(clusterFeature.geometry.toJson());
      await controller.easeTo(
        CameraOptions(center: point, zoom: double.parse(zoom.value ?? "10")),
        MapAnimationOptions(duration: 500),
      );
    }
  });
}
