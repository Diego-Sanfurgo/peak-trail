import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:peak_trail/data/models/waterfall.dart';

class WaterfallProvider {
  factory WaterfallProvider() => _instance;
  static final WaterfallProvider _instance = WaterfallProvider._internal();
  WaterfallProvider._internal();

  final String _waterfallPath = 'assets/data/cascadas.geojson';

  Future<Set<Waterfall>> fetchWaterfall() async {
    try {
      final response = await rootBundle.loadString(_waterfallPath);

      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data
          .map((e) => Waterfall.fromJson(e as Map<String, dynamic>))
          .toSet();
    } catch (e) {
      log(e.toString());
      return <Waterfall>{};
    }
  }

  Future<String> fetchWaterfallJson() async {
    try {
      final response = await rootBundle.loadString(_waterfallPath);
      return response;
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
