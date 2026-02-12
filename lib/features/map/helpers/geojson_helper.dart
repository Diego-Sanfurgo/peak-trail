import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/data/models/place.dart';

class GeoJsonHelper {
  /// 1. Filtra las features dentro del BBox.
  /// 2. Mapea las features resultantes a objetos HikingPoint.
  static List<PlaceGeometry> filterAndMapFeatures({
    required Map<String, dynamic> geoJson,
    required CoordinateBounds bounds,
  }) {
    // Validamos que exista la lista de features
    final List<dynamic>? features = geoJson['features'];
    if (features == null || features.isEmpty) return [];

    // Extraemos límites para lectura rápida
    final double minLat = bounds.southwest.coordinates.lat.toDouble();
    final double maxLat = bounds.northeast.coordinates.lat.toDouble();
    final double minLng = bounds.southwest.coordinates.lng.toDouble();
    final double maxLng = bounds.northeast.coordinates.lng.toDouble();

    final List<PlaceGeometry> visiblePoints = [];

    for (final feature in features) {
      final geometry = feature['geometry'];

      // Aseguramos que sea un punto
      if (geometry != null && geometry['type'] == 'Point') {
        final List<dynamic> coords = geometry['coordinates'];
        final double lng = (coords[0] as num).toDouble();
        final double lat = (coords[1] as num).toDouble();

        // Lógica de Filtrado (Bounding Box Check)
        // GeoJSON: [lng, lat]
        if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
          // Si pasa el filtro, creamos el objeto BasePoint
          // Asumo que tu feature tiene properties con un 'id' y 'name'
          final properties = feature['properties'] ?? {};

          visiblePoints.add(PlaceGeometry.fromJson(properties));
        }
      }
    }

    return visiblePoints;
  }
}
