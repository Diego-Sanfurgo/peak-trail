import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/environment/env.dart';

Future<void> initApp() async {
  MapboxOptions.setAccessToken(Environment.mapboxToken);

  await Future.wait([
    Supabase.initialize(
      url: Environment.supabaseURL,
      anonKey: Environment.supabasePublishable,
    ),

    LocationService.instance.init(),
  ]);
}
