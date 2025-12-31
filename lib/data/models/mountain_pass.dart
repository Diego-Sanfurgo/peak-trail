// To parse this JSON data, do
//
//     final waterfall = waterfallFromJson(jsonString);

import 'dart:convert';

import 'package:peak_trail/data/models/base_point.dart';

MountainPass mountainPassFromJson(String str) =>
    MountainPass.fromJson(json.decode(str));

String mountainPassToJson(MountainPass data) => json.encode(data.toJson());

class MountainPass extends BasePoint {
  final List<double> bbox;

  MountainPass({
    required this.bbox,
    required super.geometry,
    required super.properties,
  });

  @override
  MountainPass copyWith({
    BaseGeometry? geometry,
    BaseProperties? properties,
    List<double>? bbox,
  }) => MountainPass(
    geometry: geometry ?? this.geometry,
    properties: properties ?? this.properties,
    bbox: bbox ?? this.bbox,
  );

  factory MountainPass.fromJson(Map<String, dynamic> json) => MountainPass(
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
