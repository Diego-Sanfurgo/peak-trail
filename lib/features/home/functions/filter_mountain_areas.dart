import 'dart:convert';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> filterUserMountains(
  MapboxMap controller,
  List<String> userPeakIds,
) async {
  // Si la lista está vacía, quizás quieras ocultar todo o mostrar todo.
  // Aquí mostramos SOLO las que están en la lista.
  await controller.style.setStyleLayerProperties(
    "mountains-fill-layer",

    jsonEncode({
      // Expresión de filtrado Mapbox
      // "IN" verifica si el 'place_id' del tile existe en la lista provista
      "filter": [
        "in",
        ["get", "place_id"], // Campo en el MVT
        ["literal", userPeakIds], // Lista de IDs desde Dart
      ],
      // Cambiar color para indicar que es un filtro activo
      "fill-color": "#729B79",
    }),
  );
}

// Para restaurar y ver todas de nuevo:
Future<void> resetFilter(MapboxMap controller) async {
  await controller.style.setStyleLayerProperties(
    "mountains-fill-layer",
    jsonEncode({
      // Elimina el filtro, muestra todo
      "filter": ["all"],
      // Cambiar color para indicar que es un filtro activo
      "fill-color": "#34A853",
    }),
  );
}
