import 'dart:developer';

import 'package:flutter/services.dart';

Future<String> getGeoJsonMountains() async {
  try {
    return await rootBundle.loadString(
      'data/cerros_v2.geojson',
    );
  } on Exception catch (e) {
    log(e.toString());
    return '';
  }
}
