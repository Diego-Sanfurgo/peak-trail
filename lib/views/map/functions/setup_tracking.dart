import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void setupPositionTracking(
  MapboxMap controller,
  StreamSubscription? userPositionStream,
) {
  geo.LocationSettings settings = geo.LocationSettings(
    accuracy: geo.LocationAccuracy.best,
    distanceFilter: 50,
  );
  userPositionStream?.cancel();
  userPositionStream =
      geo.Geolocator.getPositionStream(locationSettings: settings).listen((
        geo.Position? position,
      ) {
        if (position != null) {
          controller.easeTo(
            CameraOptions(
              zoom: 12,
              center: Point(
                coordinates: Position(position.longitude, position.latitude),
              ),
            ),
            MapAnimationOptions(duration: 500),
          );
        }
      });
}
