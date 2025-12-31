// To parse this JSON data, do
//
//     final lake = lakeFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/data/models/base_multi_poligon.dart';

Lake lakeFromJson(String str) => Lake.fromJson(json.decode(str));

String lakeToJson(Lake data) => json.encode(data.toJson());

class Lake extends BaseMultiPoligon {
  final List<double> bbox;

  Lake({
    required this.bbox,
    required super.geometry,
    required super.properties,
  });

  @override
  Lake copyWith({
    BaseGeometryMultiPoligon? geometry,
    BaseProperties? properties,
    List<double>? bbox,
  }) => Lake(
    geometry: geometry ?? this.geometry,
    properties: properties ?? this.properties,
    bbox: bbox ?? this.bbox,
  );

  factory Lake.fromJson(Map<String, dynamic> json) => Lake(
    geometry: BaseGeometryMultiPoligon.fromJson(json["geometry"]),
    properties: BaseProperties.fromJson(json["properties"]),
    bbox: List<double>.from(json["bbox"].map((x) => x?.toDouble())),
  );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "bbox": List<dynamic>.from(bbox.map((x) => x)),
  };
}
