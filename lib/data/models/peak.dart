// To parse this JSON data, do
//
//     final peak = peakFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/core/utils/normalize_map.dart';
import 'package:peak_trail/data/models/base_point.dart';

Peak peakFromJson(String str) => Peak.fromJson(json.decode(str));

String peakToJson(Peak data) => json.encode(data.toJson());

class Peak extends BasePoint {
  Peak({required super.properties, required super.geometry});

  @override
  Peak copyWith({BaseProperties? properties, BaseGeometry? geometry}) => Peak(
    properties: properties ?? this.properties,
    geometry: geometry ?? this.geometry,
  );

  factory Peak.fromJson(Map<String, dynamic> json) => Peak(
    properties: BaseProperties.fromJson(json["properties"]),
    geometry: BaseGeometry.fromJson(json["geometry"]),
  );

  factory Peak.fromFeature(Map<String?, Object?> rawFeature) {
    final Map<String, dynamic> json = normalizeMap(rawFeature);
    return Peak.fromJson(json);
  }

  // Map<String, dynamic> toJson() => {
  //   "properties": properties.toJson(),
  //   "geometry": geometry.toJson(),
  // };
}

class PeakProperties extends BaseProperties {
  final int alt;

  PeakProperties({required super.name, required this.alt, required super.id});

  factory PeakProperties.fromJson(Map<String, dynamic> json) =>
      PeakProperties(name: json["name"], alt: json["alt"], id: json["id"]);

  @override
  PeakProperties copyWith({String? name, int? alt, String? id}) =>
      PeakProperties(
        name: name ?? this.name,
        alt: alt ?? this.alt,
        id: id ?? this.id,
      );

  @override
  Map<String, dynamic> toJson() => {"name": name, "alt": alt, "id": id};
}
