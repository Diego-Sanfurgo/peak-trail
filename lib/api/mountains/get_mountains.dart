import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

Future<List<Map>?> getMountains() async {
  try {
    final String jsonString = await rootBundle.loadString('data/cerros_v2.geojson');
    final Map<String, dynamic> data = json.decode(jsonString);
    final rawData = data['features'] as List;
    return rawData.map((e) => e as Map).toList();
  } on Exception catch (e) {
    log(e.toString());
    return null;
  }
}
