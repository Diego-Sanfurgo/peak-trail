import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/models/cluster_feature.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
import 'package:peak_trail/views/home/functions/add_styles.dart';

Future<void> addMountainsLayers(MapboxMap controller, String geoJson) async {
  await controller.style.addSource(
    GeoJsonSource(
      id: AppConstants.mountainsSourceId,
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
      id: AppConstants.clusterLayerId,
      sourceId: AppConstants.mountainsSourceId,
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
      id: AppConstants.clusterCountId,
      sourceId: AppConstants.mountainsSourceId,
      filter: ["has", "point_count"],
      textFieldExpression: ["get", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textIgnorePlacement: true,
      textAllowOverlap: true,
    ),
  );

  await addStyles(controller);
  if (!await controller.style.hasStyleImage(AppConstants.mountainMarkerId)) {
    await addStyles(controller);
  }

  // Puntos individuales
  await controller.style.addLayer(
    SymbolLayer(
      id: AppConstants.singlePointId,
      sourceId: AppConstants.mountainsSourceId,
      filter: [
        "!",
        ["has", "point_count"],
      ],
      iconImage: AppConstants.mountainMarkerId,
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
    AppConstants.singlePointId,
    LayerPosition(above: "cluster-count"),
  );

  await _addOnTapListener(controller);
}

Future<void> _addOnTapListener(MapboxMap controller) async {
  controller.setOnMapTapListener((MapContentGestureContext mapContext) async {
    final features = await controller.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(mapContext.touchPosition),
      RenderedQueryOptions(
        layerIds: [AppConstants.clusterLayerId],
        filter: null,
      ),
    );

    if (features.isEmpty) return;

    final QueriedRenderedFeature? cluster = features.first;
    final rawFeature = cluster!.queriedFeature.feature;

    final ClusterFeature clusterFeature = ClusterFeature.fromFeature(
      rawFeature,
    );

    // Calcular el nuevo zoom ideal para expandir este clúster
    final FeatureExtensionValue zoom = await controller
        .getGeoJsonClusterExpansionZoom(
          AppConstants.mountainsSourceId,
          clusterFeature.toJson(),
        );

    final point = Point.fromJson(clusterFeature.geometry.toJson());
    await controller.easeTo(
      CameraOptions(center: point, zoom: double.parse(zoom.value ?? "10")),
      MapAnimationOptions(duration: 500),
    );
  });
}
