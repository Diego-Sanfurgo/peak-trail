// trace_service.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:peak_trail/data/models/trace_point.dart';

class TraceService {
  static const _eventChannel = EventChannel('app/locations_stream');
  static const _methodChannel = MethodChannel('app/locations_method');

  Stream<TracePoint>? _stream;

  Stream<TracePoint> get onLocation {
    _stream ??= _eventChannel.receiveBroadcastStream().map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return TracePoint.fromJson(map);
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
    return list
        .map((e) => TracePoint.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> forceUpload() async {
    await _methodChannel.invokeMethod('forceUpload');
  }
}
