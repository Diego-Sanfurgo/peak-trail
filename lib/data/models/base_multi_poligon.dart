// To parse this JSON data, do
//
//     final basePoint = basePointFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/core/utils/normalize_map.dart';

BaseMultiPoligon baseMultiPoligonFromJson(String str) =>
    BaseMultiPoligon.fromJson(json.decode(str));

String baseMultiPoligonToJson(BaseMultiPoligon data) =>
    json.encode(data.toJson());

class BaseMultiPoligon {
  final BaseGeometryMultiPoligon geometry;
  final BaseProperties properties;

  BaseMultiPoligon({required this.geometry, required this.properties});

  BaseMultiPoligon copyWith({
    BaseGeometryMultiPoligon? geometry,
    BaseProperties? properties,
  }) => BaseMultiPoligon(
    geometry: geometry ?? this.geometry,
    properties: properties ?? this.properties,
  );

  factory BaseMultiPoligon.fromJson(Map<String, dynamic> json) =>
      BaseMultiPoligon(
        geometry: BaseGeometryMultiPoligon.fromJson(json["geometry"]),
        properties: BaseProperties.fromJson(json['properties']),
      );

  Map<String, dynamic> toJson() => {
    "geometry": geometry.toJson(),
    "properties": properties.toJson(),
  };
}

class BaseGeometryMultiPoligon {
  final String type;
  final List<List<List<double>>> coordinates;

  BaseGeometryMultiPoligon({required this.type, required this.coordinates});

  BaseGeometryMultiPoligon copyWith({
    String? type,
    List<List<List<double>>>? coordinates,
  }) => BaseGeometryMultiPoligon(
    type: type ?? this.type,
    coordinates: coordinates ?? this.coordinates,
  );

  factory BaseGeometryMultiPoligon.fromJson(Map<String, dynamic> json) =>
      BaseGeometryMultiPoligon(
        type: json["type"],
        coordinates: json['coordinates'],
      );

  factory BaseGeometryMultiPoligon.fromFeature(
    Map<String?, Object?> rawFeature,
  ) {
    final Map<String, dynamic> json = normalizeMap(rawFeature);
    return BaseGeometryMultiPoligon.fromJson(json['geometry']);
  }

  Map<String, dynamic> toJson() => {"type": type, "coordinates": coordinates};
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
