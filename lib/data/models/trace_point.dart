class TracePoint {
  final int? id;
  final double lat;
  final double lon;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final double? accuracy;
  final int timestamp; // epoch ms

  TracePoint({
    this.id,
    required this.lat,
    required this.lon,
    this.altitude,
    this.speed,
    this.bearing,
    this.accuracy,
    required this.timestamp,
  });

  factory TracePoint.fromJson(Map<String, dynamic> m) {
    return TracePoint(
      id: m['id'] == null ? null : (m['id'] as num).toInt(),
      lat: (m['lat'] as num).toDouble(),
      lon: (m['lon'] as num).toDouble(),
      altitude: m['altitude'] != null
          ? (m['altitude'] as num).toDouble()
          : null,
      speed: m['speed'] != null ? (m['speed'] as num).toDouble() : null,
      bearing: m['bearing'] != null ? (m['bearing'] as num).toDouble() : null,
      accuracy: m['accuracy'] != null
          ? (m['accuracy'] as num).toDouble()
          : null,
      timestamp: (m['timestamp'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': lat,
    'lon': lon,
    'altitude': altitude,
    'speed': speed,
    'bearing': bearing,
    'accuracy': accuracy,
    'timestamp': timestamp,
  };
}
