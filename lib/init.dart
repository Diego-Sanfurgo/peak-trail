import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'core/environment/env.dart';

Future<void> initApp() async {
  MapboxOptions.setAccessToken(Environment.mapboxToken);
}
