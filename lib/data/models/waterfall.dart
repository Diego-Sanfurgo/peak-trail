// To parse this JSON data, do
//
//     final waterfall = waterfallFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/data/models/base_point.dart';

Waterfall waterfallFromJson(String str) => Waterfall.fromJson(json.decode(str));

String waterfallToJson(Waterfall data) => json.encode(data.toJson());

class Waterfall extends BasePoint {
  final List<double> bbox;

  Waterfall({
    required this.bbox,
    required super.geometry,
    required super.properties,
  });

  @override
  Waterfall copyWith({
    BaseGeometry? geometry,
    BaseProperties? properties,
    List<double>? bbox,
  }) => Waterfall(
    geometry: geometry ?? this.geometry,
    properties: properties ?? this.properties,
    bbox: bbox ?? this.bbox,
  );

  factory Waterfall.fromJson(Map<String, dynamic> json) => Waterfall(
    geometry: BaseGeometry.fromJson(json["geometry"]),
    properties: BaseProperties.fromJson(json["properties"]),
    bbox: List<double>.from(json["bbox"].map((x) => x?.toDouble())),
  );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "bbox": List<dynamic>.from(bbox.map((x) => x)),
  };
}
