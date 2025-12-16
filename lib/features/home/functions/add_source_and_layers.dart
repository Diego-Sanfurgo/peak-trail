import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'add_image_to_style.dart';

Future<void> addSourceAndLayers(
  MapboxMap controller,
  String geoJson,
  String sourceBaseID,
) async {
  final String sourceID = '$sourceBaseID-source';
  final bool isPeak = sourceBaseID.contains('peak');
  await controller.style.addSource(
    GeoJsonSource(
      id: sourceID,
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
      id: '$sourceBaseID-cluster',
      sourceId: sourceID,
      circleColor: isPeak ? Colors.black38.toARGB32() : Colors.blue.toARGB32(),
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
      id: '$sourceBaseID-count',
      sourceId: sourceID,
      filter: ["has", "point_count"],
      textFieldExpression: ["get", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textIgnorePlacement: true,
      textAllowOverlap: true,
    ),
  );

  // Puntos individuales
  await controller.style.addLayer(
    SymbolLayer(
      id: '$sourceBaseID-unclustered-points',
      sourceId: sourceID,
      filter: [
        "!",
        ["has", "point_count"],
      ],
      iconImage: '$sourceBaseID-marker',
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

      textFieldExpression: sourceBaseID.contains('peak')
          ? ["get", "name"]
          : ["get", "fna"],
      iconSize: 1,
      textOffset: [0, 1.8],
      textColor: Colors.black.toARGB32(),
      textSize: 14.0,
      textHaloColor: Colors.white.toARGB32(),
      textHaloWidth: 1.5,
    ),
  );

  do {
    await addImageToStyle(controller, sourceBaseID);
  } while (!await controller.style.hasStyleImage('$sourceBaseID-marker'));

  // La capa de puntos individuales debe ir POR ENCIMA de los clusters
  // await controller.style.moveStyleLayer(
  //   MapConstants.singlePointId,
  //   LayerPosition(above: "cluster-count"),
  // );
}
