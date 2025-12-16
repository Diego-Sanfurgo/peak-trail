import 'dart:developer';

import 'package:flutter/services.dart';

class PeakProvider {
  factory PeakProvider() => _instance;
  static final PeakProvider _instance = PeakProvider._internal();
  PeakProvider._internal();

  final String _geoJsonPath = 'assets/data/cerros_v3.geojson';

  Future<String?> fetchGeojsonPeaks() async {
    try {
      return await rootBundle.loadString(_geoJsonPath);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
