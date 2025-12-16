import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/data/models/base_point.dart';

Future<void> addOnMapTapListener(
  MapboxMap controller,
  List<String> sourceBaseIDList,
) async {
  List<String> layerIDList = [];

  for (var sourceBaseID in sourceBaseIDList) {
    layerIDList.addAll([
      '$sourceBaseID-cluster',
      '$sourceBaseID-unclustered-points',
    ]);
  }

  controller.setOnMapTapListener((MapContentGestureContext mapContext) async {
    final List<QueriedRenderedFeature?> features = await controller
        .queryRenderedFeatures(
          RenderedQueryGeometry.fromScreenCoordinate(mapContext.touchPosition),
          RenderedQueryOptions(layerIds: layerIDList, filter: null),
        );

    if (features.isEmpty) return;

    final QueriedRenderedFeature? feature = features.first;
    final rawFeature = feature!.queriedFeature.feature;
    final List<String> layerStrings = feature.layers.single!.split('-');

    double zoom = 14.5;

    if (layerStrings.contains('cluster')) {
      // Calcular el nuevo zoom ideal para expandir este clúster
      final FeatureExtensionValue featureZoom = await controller
          .getGeoJsonClusterExpansionZoom(
            '${layerStrings.first}-source',
            rawFeature,
          );
      zoom = double.parse(featureZoom.value ?? '10');
    }

    final BaseGeometry baseGeometry = BaseGeometry.fromFeature(rawFeature);
    final point = Point.fromJson(baseGeometry.coordinates.toJson());

    await controller.easeTo(
      CameraOptions(center: point, zoom: zoom),
      MapAnimationOptions(duration: 500),
    );

    //   // Des-seleccionar anterior
    //   // if (_selectedFeatureId != null) {
    //   //   await controller.setFeatureState(
    //   //     AppConstants.mountainsSourceId,
    //   //     _selectedFeatureId!,
    //   //     {"selected": false},
    //   //   );
    //   // }

    //   // Seleccionar nuevo
    // await controller.setFeatureState(
    //   '$sourceBaseID-source',
    //   null,
    //   normalizeMap(rawFeature)['properties']['id'],
    //   jsonEncode({"selected": true}),
    // );

    //   // _selectedFeatureId = featureId;
  });
}
