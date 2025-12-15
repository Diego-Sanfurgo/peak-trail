// To parse this JSON data, do
//
//     final mountain = mountainFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/utils/normalize_map.dart';

Mountain mountainFromJson(String str) => Mountain.fromJson(json.decode(str));

String mountainToJson(Mountain data) => json.encode(data.toJson());

class Mountain {
  Mountain({
    // required this.type,
    required this.id,
    required this.coordinates,
    // required this.geometryName,
    required this.properties,
    // required this.bbox,
  });

  factory Mountain.fromJson(Map<String, dynamic> json) => Mountain(
    // type: json["type"],
    id: json["properties"]["id"],
    coordinates: Coordinates.fromJson(json["geometry"]),
    // geometryName: json["geometry_name"],
    properties: Properties.fromJson(json["properties"]),
    // bbox: List<double>.from(json["bbox"].map((x) => x?.toDouble())),
  );

  factory Mountain.fromFeature(Map<String?, Object?> rawFeature) {
    final Map<String, dynamic> json = normalizeMap(rawFeature);
    return Mountain.fromJson(json);
  }
  // final String type;
  final String id;
  final Coordinates coordinates;
  // final String geometryName;
  final Properties properties;
  // final List<double>? bbox;

  Mountain copyWith({
    // String? type,
    String? id,
    Coordinates? coordinates,
    // String? geometryName,
    Properties? properties,
    // List<double>? bbox,
  }) => Mountain(
    // type: type ?? this.type,
    id: id ?? this.id,
    coordinates: coordinates ?? this.coordinates,
    // geometryName: geometryName ?? this.geometryName,
    properties: properties ?? this.properties,
    // bbox: bbox ?? this.bbox,
  );

  Map<String, dynamic> toJson() => {
    // "type": type,
    "id": id,
    "geometry": coordinates.toJson(),
    // "geometry_name": geometryName,
    "properties": properties.toJson(),
    // "bbox": List<dynamic>.from(bbox.map((x) => x)),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Mountain && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class Coordinates {
  Coordinates({
    // required this.type,
    required this.list,
    required this.lng,
    required this.lat,
  });

  // Coordinates copyWith({
  //   // String? type,
  //   List<double>? coordinates,
  // }) => Coordinates(
  //   // type: type ?? this.type,
  //   coordinates: coordinates ?? this.coordinates,
  //   lng: null,
  //   lat: null,
  // );

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    final coordinatesList = List<double>.from(
      json["coordinates"].map((x) => x?.toDouble()),
    );
    return Coordinates(
      // type: json["type"],
      list: coordinatesList,
      lng: coordinatesList.first,
      lat: coordinatesList.last,
    );
  }
  // final String type;
  final List<double> list;
  final double lng;
  final double lat;

  Map<String, dynamic> toJson() => {
    // "type": type,
    "coordinates": List<dynamic>.from(list.map((x) => x)),
  };

  @override
  String toString() => 'Lat: $lat, Lng: $lng';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Coordinates && other.lat == lat && other.lng == lng);

  @override
  int get hashCode => list.hashCode;
}

class Properties {
  Properties({
    required this.id,
    // required this.entidad,
    // required this.fna,
    // required this.gna,
    required this.name,
    required this.alt,
    // required this.fdc,
    // required this.sag,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    id: json["id"],
    // entidad: json["entidad"],
    // fna: json["fna"],
    // gna: json["gna"],
    name: json["name"],
    alt: json["alt"],
    // fdc: json["fdc"],
    // sag: json["sag"],
  );
  final String id;
  // final int entidad;
  // final String? fna;
  // final String? gna;
  final String name;
  final int alt;
  // final String? fdc;
  // final String? sag;

  Properties copyWith({
    String? id,
    // int? entidad,
    // String? fna,
    // String? gna,
    String? name,
    int? alt,
    // String? fdc,
    // String? sag,
  }) => Properties(
    id: id ?? this.id,
    // entidad: entidad ?? this.entidad,
    // fna: fna ?? this.fna,
    // gna: gna ?? this.gna,
    name: name ?? this.name,
    alt: alt ?? this.alt,
    // fdc: fdc ?? this.fdc,
    // sag: sag ?? this.sag,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "entidad": entidad,
    // "fna": fna,
    // "gna": gna,
    "nam": name,
    "alt": alt,
    // "fdc": fdc,
    // "sag": sag,
  };
}
