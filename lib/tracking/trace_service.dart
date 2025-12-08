// trace_service.dart
import 'dart:async';
import 'package:flutter/services.dart';

class TracePoint {
  final int? id;
  final double lat;
  final double lon;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final double? accuracy;
  final int timestamp; // epoch ms

  TracePoint({this.id, required this.lat, required this.lon, this.altitude, this.speed, this.bearing, this.accuracy, required this.timestamp});

  factory TracePoint.fromMap(Map m) {
    return TracePoint(
      id: m['id'] == null ? null : (m['id'] as num).toInt(),
      lat: (m['lat'] as num).toDouble(),
      lon: (m['lon'] as num).toDouble(),
      altitude: m['altitude'] != null ? (m['altitude'] as num).toDouble() : null,
      speed: m['speed'] != null ? (m['speed'] as num).toDouble() : null,
      bearing: m['bearing'] != null ? (m['bearing'] as num).toDouble() : null,
      accuracy: m['accuracy'] != null ? (m['accuracy'] as num).toDouble() : null,
      timestamp: (m['timestamp'] as num).toInt(),
    );
  }

  Map toMap() => {
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

class TraceService {
  static const _eventChannel = EventChannel('app/locations_stream');
  static const _methodChannel = MethodChannel('app/locations_method');

  Stream<TracePoint>? _stream;

  Stream<TracePoint> get onLocation {
    _stream ??= _eventChannel.receiveBroadcastStream().map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return TracePoint.fromMap(map);
    });
    return _stream!;
  }

  Future<void> startTracking() async {
    await _methodChannel.invokeMethod('startTracking');
  }

  Future<void> stopTracking() async {
    await _methodChannel.invokeMethod('stopTracking');
  }

  Future<List<TracePoint>> getAllTraces() async {
    final res = await _methodChannel.invokeMethod('getAllTraces');
    final List list = res as List;
    return list.map((e) => TracePoint.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> forceUpload() async {
    await _methodChannel.invokeMethod('forceUpload');
  }
}
