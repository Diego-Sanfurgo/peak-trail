import 'dart:convert';
import 'dart:developer';

import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/providers/peak_provider.dart';

class PeakRepository {
  PeakRepository(this._provider);

  final PeakProvider _provider;

  Future<Set<Peak>> getPeaks() async {
    try {
      final String? response = await _provider.fetchGeojsonPeaks();
      if (response == null) {
        throw Exception('Null response');
      }
      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data.map((e) => Peak.fromJson(e as Map<String, dynamic>)).toSet();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getPeaksJson() async {
    try {
      String? response = await _provider.fetchGeojsonPeaks();
      if (response == null) {
        throw Exception('Null response');
      }
      return response;
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }
}
