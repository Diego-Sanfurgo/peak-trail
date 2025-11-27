import 'dart:developer';

import 'package:flutter/services.dart';

Future<String> getGeoJsonMountains() async {
  try {
    return await rootBundle.loadString(
      'data/cerros_unificados_DBSCAN_limpio.geojson',
    );
  } on Exception catch (e) {
    log(e.toString());
    return '';
  }
}
