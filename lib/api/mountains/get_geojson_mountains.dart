import 'dart:developer';

import 'package:flutter/services.dart';

Future<String> getGeoJsonMountains() async {
  try {
    return await rootBundle.loadString('data/peaks.json');
    // final Map<String, dynamic> data = json.decode(jsonString);
  } on Exception catch (e) {
    log(e.toString());
    return '';
  }
}
