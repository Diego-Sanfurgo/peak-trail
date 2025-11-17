// To parse this JSON data, do
//
//     final clusterFeature = clusterFeatureFromJson(jsonString);

import 'dart:convert';

ClusterFeature clusterFeatureFromJson(String str) =>
    ClusterFeature.fromJson(json.decode(str));

String clusterFeatureToJson(ClusterFeature data) => json.encode(data.toJson());

class ClusterFeature {
  final String type;
  final String id;
  final Geometry geometry;
  final Properties properties;

  ClusterFeature({
    required this.type,
    required this.id,
    required this.geometry,
    required this.properties,
  });

  ClusterFeature copyWith({
    String? type,
    String? id,
    Geometry? geometry,
    Properties? properties,
  }) => ClusterFeature(
    type: type ?? this.type,
    id: id ?? this.id,
    geometry: geometry ?? this.geometry,
    properties: properties ?? this.properties,
  );

  factory ClusterFeature.fromJson(Map<String, dynamic> json) => ClusterFeature(
    type: json["type"],
    id: json["id"],
    geometry: Geometry.fromJson(json["geometry"]),
    properties: Properties.fromJson(json["properties"]),
  );

  factory ClusterFeature.fromFeature(Map<String?, Object?> rawFeature) {
    final Map<String, dynamic> json = _normalizeMap(rawFeature);
    return ClusterFeature(
      type: json["type"],
      id: json["id"],
      geometry: Geometry.fromJson(json["geometry"]),
      properties: Properties.fromJson(json["properties"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "geometry": geometry.toJson(),
    "properties": properties.toJson(),
  };
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  Geometry copyWith({String? type, List<double>? coordinates}) => Geometry(
    type: type ?? this.type,
    coordinates: coordinates ?? this.coordinates,
  );

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json["type"],
    coordinates: List<double>.from(
      json["coordinates"].map((x) => x?.toDouble()),
    ),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}

class Properties {
  final int clusterId;
  final bool cluster;
  final int pointCountAbbreviated;
  final int pointCount;

  Properties({
    required this.clusterId,
    required this.cluster,
    required this.pointCountAbbreviated,
    required this.pointCount,
  });

  Properties copyWith({
    int? clusterId,
    bool? cluster,
    int? pointCountAbbreviated,
    int? pointCount,
  }) => Properties(
    clusterId: clusterId ?? this.clusterId,
    cluster: cluster ?? this.cluster,
    pointCountAbbreviated: pointCountAbbreviated ?? this.pointCountAbbreviated,
    pointCount: pointCount ?? this.pointCount,
  );

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    clusterId: json["cluster_id"],
    cluster: json["cluster"],
    pointCountAbbreviated: json["point_count_abbreviated"] is String
        ? int.tryParse(json["point_count_abbreviated"]) ?? 0
        : json["point_count_abbreviated"],
    pointCount: json["point_count"] is String
        ? int.tryParse(json["point_count"]) ?? 0
        : json["point_count"],
  );

  Map<String, dynamic> toJson() => {
    "cluster_id": clusterId,
    "cluster": cluster,
    "point_count_abbreviated": pointCountAbbreviated,
    "point_count": pointCount,
  };
}

Map<String, dynamic> _normalizeMap(Map? m) {
  final result = <String, dynamic>{};
  if (m == null) return result;
  m.forEach((key, value) {
    final k = key?.toString() ?? '';
    result[k] = _normalizeValue(value);
  });
  return result;
}

dynamic _normalizeValue(dynamic v) {
  if (v is Map) return _normalizeMap(v);
  if (v is List) return v.map(_normalizeValue).toList();
  return v;
}
