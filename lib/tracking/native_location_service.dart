import 'package:flutter/services.dart';

class NativeLocationService {
  static const _platform = MethodChannel('com.example.peak_trail/location');

  /// Inicia el servicio de rastreo nativo (Foreground Service en Android)
  Future<void> startTracking() async {
    try {
      await _platform.invokeMethod('startTracking');
      print("Flutter: Solicitud de inicio enviada.");
    } on PlatformException catch (e) {
      print("Flutter: Error al iniciar tracking: '${e.message}'.");
    }
  }

  /// Detiene el servicio
  Future<void> stopTracking() async {
    try {
      await _platform.invokeMethod('stopTracking');
      print("Flutter: Solicitud de parada enviada.");
    } on PlatformException catch (e) {
      print("Flutter: Error al detener tracking: '${e.message}'.");
    }
  }
}