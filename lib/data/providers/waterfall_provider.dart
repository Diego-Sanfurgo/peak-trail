import 'dart:developer';

import 'package:flutter/services.dart';

class WaterfallProvider {
  factory WaterfallProvider() => _instance;
  static final WaterfallProvider _instance = WaterfallProvider._internal();
  WaterfallProvider._internal();

  final String _waterfallPath = 'assets/data/cascadas.geojson';

  Future<String?> fetchWaterfall() async {
    try {
      return await rootBundle.loadString(_waterfallPath);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
