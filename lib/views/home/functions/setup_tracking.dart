import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/controllers/location_service.dart';

void setupPositionTracking(MapboxMap controller) {
  LocationService.instance.positionStream.listen((position) {
    controller.easeTo(
      CameraOptions(
        zoom: 12,
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
      ),
      MapAnimationOptions(duration: 500),
    );
  });
}
