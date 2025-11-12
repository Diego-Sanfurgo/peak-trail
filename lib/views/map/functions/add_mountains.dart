import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> addMountainsLayers(MapboxMap controller, String geoJson) async {
  String sourceId = 'mountains_source';

  controller.style.addSource(
    GeoJsonSource(
      id: sourceId,
      data: geoJson,
      cluster: true,
      clusterMinPoints: 2,
      clusterMaxZoom: 10,
      clusterRadius: 20,
    ),
  );

  //Cluster layer
  await controller.style.addLayer(
    CircleLayer(
      id: "cluster-layer",
      sourceId: sourceId,
      circleColor: 0xFF679436,
      circleRadius: 10,
    ),
  );

  // final mountainIcon = await ImageController.loadImage(
  //   AppAssets.mountainIcon,
  // );

  // Texto del cluster
  await controller.style.addLayer(
    SymbolLayer(
      id: "cluster-count",
      sourceId: sourceId,
      textField: "cumbres",
      textSize: 10,
      textColor: 0xFFFFFFFF,
    ),
  );

  // Puntos individuales
  await controller.style.addLayer(
    CircleLayer(
      id: "unclustered-points",
      sourceId: sourceId,
      circleColor: 0xFF11B4DA,
      circleRadius: 12,
      circleStrokeWidth: 1.5,
      circleStrokeColor: 0xFFFFFFFF,
      filter: [
        "!",
        ["has", "point_count"],
      ],
    ),
  );
}
