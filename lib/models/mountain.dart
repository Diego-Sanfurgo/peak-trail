// To parse this JSON data, do
//
//     final mountain = mountainFromJson(jsonString);

import 'dart:convert';

Mountain mountainFromJson(String str) => Mountain.fromJson(json.decode(str));

String mountainToJson(Mountain data) => json.encode(data.toJson());

class Mountain {
  // final String type;
  final String id;
  final Coordinates coordinates;
  // final String geometryName;
  final Properties properties;
  final List<double> bbox;

  Mountain({
    // required this.type,
    required this.id,
    required this.coordinates,
    // required this.geometryName,
    required this.properties,
    required this.bbox,
  });

  Mountain copyWith({
    // String? type,
    String? id,
    Coordinates? coordinates,
    // String? geometryName,
    Properties? properties,
    List<double>? bbox,
  }) => Mountain(
    // type: type ?? this.type,
    id: id ?? this.id,
    coordinates: coordinates ?? this.coordinates,
    // geometryName: geometryName ?? this.geometryName,
    properties: properties ?? this.properties,
    bbox: bbox ?? this.bbox,
  );

  factory Mountain.fromJson(Map<String, dynamic> json) => Mountain(
    // type: json["type"],
    id: json["id"],
    coordinates: Coordinates.fromJson(json["geometry"]),
    // geometryName: json["geometry_name"],
    properties: Properties.fromJson(json["properties"]),
    bbox: List<double>.from(json["bbox"].map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    // "type": type,
    "id": id,
    "geometry": coordinates.toJson(),
    // "geometry_name": geometryName,
    "properties": properties.toJson(),
    "bbox": List<dynamic>.from(bbox.map((x) => x)),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Mountain && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class Coordinates {
  // final String type;
  final List<double> coordinates;
  final double lng;
  final double lat;

  Coordinates({
    // required this.type,
    required this.coordinates,
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
      coordinates: coordinatesList,
      lng: coordinatesList.first,
      lat: coordinatesList.last,
    );
  }

  Map<String, dynamic> toJson() => {
    // "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}

class Properties {
  final int gid;
  final int entidad;
  final String fna;
  final String gna;
  final String nam;
  final int alt;
  final String fdc;
  final String sag;

  Properties({
    required this.gid,
    required this.entidad,
    required this.fna,
    required this.gna,
    required this.nam,
    required this.alt,
    required this.fdc,
    required this.sag,
  });

  Properties copyWith({
    int? gid,
    int? entidad,
    String? fna,
    String? gna,
    String? nam,
    int? alt,
    String? fdc,
    String? sag,
  }) => Properties(
    gid: gid ?? this.gid,
    entidad: entidad ?? this.entidad,
    fna: fna ?? this.fna,
    gna: gna ?? this.gna,
    nam: nam ?? this.nam,
    alt: alt ?? this.alt,
    fdc: fdc ?? this.fdc,
    sag: sag ?? this.sag,
  );

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    gid: json["gid"],
    entidad: json["entidad"],
    fna: json["fna"],
    gna: json["gna"],
    nam: json["nam"],
    alt: json["alt"],
    fdc: json["fdc"],
    sag: json["sag"],
  );

  Map<String, dynamic> toJson() => {
    "gid": gid,
    "entidad": entidad,
    "fna": fna,
    "gna": gna,
    "nam": nam,
    "alt": alt,
    "fdc": fdc,
    "sag": sag,
  };
}
