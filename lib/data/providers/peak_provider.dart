import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:peak_trail/data/models/peak.dart';

class PeakProvider {
  factory PeakProvider() => _instance;
  static final PeakProvider _instance = PeakProvider._internal();
  PeakProvider._internal();

  final String _geoJsonPath = 'assets/data/cerros_v3.geojson';

  Future<Set<Peak>> fetchPeaks() async {
    try {
      final response = await rootBundle.loadString(_geoJsonPath);

      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data.map((e) => Peak.fromJson(e as Map<String, dynamic>)).toSet();
    } catch (e) {
      log(e.toString());
      return <Peak>{};
    }
  }

  Future<dynamic> fetchPeaksJson({bool asString = false}) async {
    try {
      final response = await rootBundle.loadString(_geoJsonPath);
      return asString ? response : jsonDecode(response);
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
