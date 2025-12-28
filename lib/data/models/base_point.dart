// To parse this JSON data, do
//
//     final basePoint = basePointFromJson(jsonString);

import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:peak_trail/core/utils/normalize_map.dart';

BasePoint basePointFromJson(String str) => BasePoint.fromJson(json.decode(str));

String basePointToJson(BasePoint data) => json.encode(data.toJson());

class BasePoint {
  final BaseGeometry geometry;
  final BaseProperties properties;

  BasePoint({required this.geometry, required this.properties});

  BasePoint copyWith({BaseGeometry? geometry, BaseProperties? properties}) =>
      BasePoint(
        geometry: geometry ?? this.geometry,
        properties: properties ?? this.properties,
      );

  factory BasePoint.fromJson(Map<String, dynamic> json) => BasePoint(
    geometry: BaseGeometry.fromJson(json["geometry"]),
    properties: BaseProperties.fromJson(json['properties']),
  );

  Map<String, dynamic> toJson() => {
    "geometry": geometry.toJson(),
    "properties": properties.toJson(),
  };
}

class BaseGeometry {
  final String type;
  final LatLng coordinates;

  BaseGeometry({required this.type, required this.coordinates});

  BaseGeometry copyWith({String? type, LatLng? coordinates}) => BaseGeometry(
    type: type ?? this.type,
    coordinates: coordinates ?? this.coordinates,
  );

  factory BaseGeometry.fromJson(Map<String, dynamic> json) =>
      BaseGeometry(type: json["type"], coordinates: LatLng.fromJson(json));

  factory BaseGeometry.fromFeature(Map<String?, Object?> rawFeature) {
    final Map<String, dynamic> json = normalizeMap(rawFeature);
    return BaseGeometry.fromJson(json['geometry']);
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates.toJson()['coordinates'],
  };

  mb.Position toMapboxPosition() =>
      mb.Position(coordinates.longitude, coordinates.latitude);

  mb.Point toMapboxPoint() => mb.Point.fromJson(coordinates.toJson());
  geo.Position toGeoPosition() => geo.Position.fromMap(coordinates.toJson());
}

class BaseProperties {
  final String name;
  final String id;

  BaseProperties({required this.name, required this.id});

  BaseProperties copyWith({String? name, int? alt, String? id}) =>
      BaseProperties(name: name ?? this.name, id: id ?? this.id);

  factory BaseProperties.fromJson(Map<String, dynamic> json) =>
      BaseProperties(name: json["name"], id: json["id"]);

  Map<String, dynamic> toJson() => {"name": name, "id": id};
}
