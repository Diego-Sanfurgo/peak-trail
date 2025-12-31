import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../models/lake.dart';

class LakeProvider {
  factory LakeProvider() => _instance;
  static final LakeProvider _instance = LakeProvider._internal();
  LakeProvider._internal();

  final String _passPath = 'assets/data/espejos_agua.geojson';

  Future<Set<Lake>> fetchLakes() async {
    try {
      final response = await rootBundle.loadString(_passPath);

      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data.map((e) => Lake.fromJson(e as Map<String, dynamic>)).toSet();
    } catch (e) {
      log(e.toString());
      return <Lake>{};
    }
  }

  Future<String> fetchLakesJson() async {
    try {
      final response = await rootBundle.loadString(_passPath);
      return response;
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
