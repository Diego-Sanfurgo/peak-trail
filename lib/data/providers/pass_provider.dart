import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../models/mountain_pass.dart';

class MountainPassProvider {
  factory MountainPassProvider() => _instance;
  static final MountainPassProvider _instance =
      MountainPassProvider._internal();
  MountainPassProvider._internal();

  final String _passPath = 'assets/data/portezuelos.geojson';

  Future<Set<MountainPass>> fetchPass() async {
    try {
      final response = await rootBundle.loadString(_passPath);

      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data
          .map((e) => MountainPass.fromJson(e as Map<String, dynamic>))
          .toSet();
    } catch (e) {
      log(e.toString());
      return <MountainPass>{};
    }
  }

  Future<String> fetchPassJson() async {
    try {
      final response = await rootBundle.loadString(_passPath);
      return response;
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
