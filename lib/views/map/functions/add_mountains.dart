import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/views/map/functions/add_styles.dart';

Future<void> addMountainsLayers(MapboxMap controller, String geoJson) async {
  const String sourceId = 'mountains_source';
  const String markerId = 'mountain_marker';

  controller.style.addSource(
    GeoJsonSource(
      id: sourceId,
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
      id: "cluster-layer",
      sourceId: sourceId,
      circleColor: Colors.red.toARGB32(),
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
      id: "cluster-count",
      sourceId: sourceId,
      filter: ["has", "point_count"],
      textFieldExpression: ["get", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textIgnorePlacement: true,
      textAllowOverlap: true,
    ),
  );

  await addStyles(controller);
  if (!await controller.style.hasStyleImage(markerId)) {
    await addStyles(controller);
  }

  // Puntos individuales
  await controller.style.addLayer(
    SymbolLayer(
      id: "unclustered-points",
      sourceId: sourceId,
      filter: [
        "!",
        ["has", "point_count"],
      ],
      iconImage: markerId,
      iconOpacityExpression: [
        "case",
        ["has", "point_count"], // si es cluster
        0.0, // no mostrar ícono
        1.0, // mostrarlo normalmente
      ],

      textFieldExpression: ["get", "fna"],
      iconSize: 0.8,
      textOffset: [0, 1.5],
      textColor: Colors.black.toARGB32(),
      textSize: 12.0,
      textHaloColor: Colors.white.toARGB32(),
      textHaloWidth: 1.5,
    ),
  );

  // La capa de puntos individuales debe ir POR ENCIMA de los clusters
  await controller.style.moveStyleLayer(
    "unclustered-points",
    LayerPosition(above: "cluster-count"),
  );

  await _addOnTapListener(controller);
}

Future<void> _addOnTapListener(MapboxMap controller) async {
  controller.setOnMapTapListener((MapContentGestureContext mapContext) async {
    final features = await controller.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(mapContext.touchPosition),
      RenderedQueryOptions(layerIds: ["cluster-circles"], filter: null),
    );

    if (features.isEmpty) return;

    final QueriedRenderedFeature? cluster = features.first;
    final clusterId = cluster?.queriedFeature.feature["cluster_id"];
    if (clusterId == null) return;

    // Calcular el nuevo zoom ideal para expandir este clúster
    final FeatureExtensionValue zoom = await controller
        .getGeoJsonClusterExpansionZoom(
          "mountains_source",
          cluster!.queriedFeature.feature,
        );
    //  style
    //     .getSourceAsGeoJson("cluster-source")
    //     ?.getClusterExpansionZoom(clusterId);

    // if (zoom != null) {

    log(zoom.toString());
    final coords = cluster.queriedFeature.feature["coordinates"];
    // final coords = cluster.feature?.geometry?["coordinates"];
    final point = Point.fromJson({"type": "Point", "coordinates": coords});
    await controller.easeTo(
      CameraOptions(center: point /*zoom: zoom.value*/),
      MapAnimationOptions(duration: 800),
    );
    // }
  });
  // controller.onMapTapListener = (MapContentGestureContext mapContext) async {};
}
