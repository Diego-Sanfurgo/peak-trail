import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> filterVisiblePoints(
  MapboxMap controller,
  CameraState camera,
) async {
  if (!await controller.style.styleLayerExists("points")) return;

  final visibleRegion = await controller.coordinateBoundsForCamera(
    camera.toCameraOptions(),
  );

  final bboxPolygon = {
    "type": "Polygon",
    "coordinates": [
      [
        [
          visibleRegion.southwest.coordinates.lng,
          visibleRegion.southwest.coordinates.lat,
        ],
        [
          visibleRegion.northeast.coordinates.lng,
          visibleRegion.southwest.coordinates.lat,
        ],
        [
          visibleRegion.northeast.coordinates.lng,
          visibleRegion.northeast.coordinates.lat,
        ],
        [
          visibleRegion.southwest.coordinates.lng,
          visibleRegion.northeast.coordinates.lat,
        ],
        [
          visibleRegion.southwest.coordinates.lng,
          visibleRegion.southwest.coordinates.lat,
        ],
      ],
    ],
  };

  Layer layer = await controller.style.getLayer("points") as Layer;
  layer.filter = ["within", bboxPolygon];
  await controller.style.updateLayer(layer);
}
