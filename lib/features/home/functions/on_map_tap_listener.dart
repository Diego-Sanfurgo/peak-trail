import 'dart:async'; // Necesario para StreamController

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/utils/normalize_map.dart';
import 'package:peak_trail/data/models/base_point.dart';
import 'package:peak_trail/features/home/dto/selected_feature_dto.dart';

Stream<SelectedFeatureDTO> addOnMapTapListener(
  MapboxMap controller,
  List<String> sourceBaseIDList,
) {
  final streamController = StreamController<SelectedFeatureDTO>();

  List<String> layerIDList = [];
  for (var sourceBaseID in sourceBaseIDList) {
    layerIDList.addAll(['$sourceBaseID-cluster', '$sourceBaseID-points']);
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
    final bool isCluster = layerStrings.contains('cluster');
    final String sourceIDSelected = '${layerStrings.first}-source';

    if (isCluster) {
      final FeatureExtensionValue featureZoom = await controller
          .getGeoJsonClusterExpansionZoom(sourceIDSelected, rawFeature);
      zoom = double.parse(featureZoom.value ?? '14.5');
    }

    final BaseGeometry baseGeometry = BaseGeometry.fromFeature(rawFeature);

    await controller.easeTo(
      CameraOptions(center: baseGeometry.toMapboxPoint(), zoom: zoom),
      MapAnimationOptions(duration: 500),
    );

    final normalizedMap = normalizeMap(rawFeature);

    streamController.add(
      SelectedFeatureDTO(
        featureId: isCluster
            ? ''
            : normalizedMap['properties']['id'] ?? normalizedMap['id'],
        isCluster: isCluster,
        sourceID: sourceIDSelected,
      ),
    );
  });

  // Retornamos el stream para que el Bloc pueda escucharlo
  return streamController.stream;
}
