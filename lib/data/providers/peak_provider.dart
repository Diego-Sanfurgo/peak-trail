import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:peak_trail/data/models/mountain.dart';

class PeakProvider {
  factory PeakProvider() => _instance;
  static final PeakProvider _instance = PeakProvider._internal();
  PeakProvider._internal();

  final String _geoJsonPath = 'assets/data/cerros_v3.geojson';

  Future<Set<Mountain>?> fetchPeaks() async {
    try {
      final String jsonString = await rootBundle.loadString(_geoJsonPath);
      final Map<String, dynamic> geojson = json.decode(jsonString);
      final rawData = geojson['features'] as List;
      final List<Map> data = rawData.map((e) => e as Map).toList();

      return data
          .map((e) => Mountain.fromJson(e as Map<String, dynamic>))
          .toSet();
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<String> fetchGeojsonPeaks() async {
    try {
      return await rootBundle.loadString(_geoJsonPath);
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
