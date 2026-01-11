import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/data/providers/tracking_database.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

Future<void> addTrackingPolilyne(
  MapboxMap controller,
  geo.Position position,
) async {
  // 1. Crear una fuente GeoJSON vacía
  final source = GeoJsonSource(
    id: MapConstants.trackingSourceID,
    data: Feature(
      id: MapConstants.trackingFeatureID,
      geometry: LineString(
        coordinates: [Position(position.longitude, position.latitude)],
      ),
    ).toJson().toString(),
  );

  final polylineManager = await controller.annotations
      .createPolylineAnnotationManager();
  polylineManager.createMulti([
    PolylineAnnotationOptions(
      geometry: LineString(
        coordinates: [Position(position.longitude, position.latitude)],
      ),

      lineColor: Colors.orange.toARGB32(),
      lineWidth: 5.0,
      lineJoin: LineJoin.ROUND,
    ),
  ]);

  // Stream.periodic(
  //   const Duration(seconds: 2),
  // ).asyncMap((_) => TrackingDatabase().getAllPoints()).listen((points) {
  //   List<Position> coordinates = points
  //       .map((p) => Position(p.longitude, p.latitude))
  //       .toList();

  //   log("Updating polyline with ${coordinates.length} points");

  //   polylineManager.deleteAll();
  //   polylineManager.createMulti([
  //     PolylineAnnotationOptions(
  //       geometry: LineString(coordinates: coordinates),
  //       lineColor: Colors.orange.toARGB32(),
  //       lineWidth: 5.0,
  //       lineJoin: LineJoin.ROUND,
  //     ),
  //   ]);
  // });

  await controller.style.addSource(source);

  // 2. Crear la capa de línea conectada a esa fuente
  final LineLayer layer = LineLayer(
    id: MapConstants.trackingLayerID,
    sourceId: MapConstants.trackingSourceID,
    lineWidth: 5.0,
    lineColor: Colors.orange.toARGB32(), // O el color hexadecimal en int
    lineCap: LineCap.ROUND,
    lineJoin: LineJoin.ROUND,
  );

  await controller.style.addLayer(layer);
}

Future<void> actualizarRutaEnMapa(
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
