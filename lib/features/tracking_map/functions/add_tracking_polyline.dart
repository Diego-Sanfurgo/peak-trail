import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/data/providers/tracking_database.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

Future<void> updateMapTrack(
  List<TrackingPoint> puntosBackend,
  MapboxMap? controller,
) async {
  if (controller == null || puntosBackend.isEmpty) return;

  // 1. Convertir tus puntos al formato de Mapbox (Position: [lng, lat])
  // Recuerda: Mapbox usa Longitud, Latitud.
  List<Position> coordenadas = puntosBackend
      .map((p) => Position(p.longitude, p.latitude)) // Ojo al orden
      .toList();

  // 2. Crear la estructura GeoJSON
  // En el SDK v10+ se pasa el objeto Feature o la data serializada
  var nuevaData = Feature(
    id: MapConstants.trackingFeatureID,
    geometry: LineString(coordinates: coordenadas),
  );

  // 3. Actualizar la fuente existente
  // El truco en Flutter es "recuperar" la fuente y actualizar su data
  await controller.style.setStyleSourceProperty(
    MapConstants.trackingSourceID,
    "data",
    nuevaData.toJson(),
  );
}
