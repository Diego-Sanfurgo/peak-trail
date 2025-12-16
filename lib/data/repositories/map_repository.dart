import 'dart:convert';
import 'dart:developer';

import 'package:peak_trail/data/providers/peak_provider.dart';
import 'package:peak_trail/data/providers/waterfall_provider.dart';

import '../models/peak.dart';
import '../models/waterfall.dart';

class MapRepository {
  MapRepository(this._peakProvider, this._waterfallProvider);

  final PeakProvider _peakProvider;
  final WaterfallProvider _waterfallProvider;

  Future<Set<Peak>> getPeaks() async {
    try {
      final String? response = await _peakProvider.fetchGeojsonPeaks();
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
      String? response = await _peakProvider.fetchGeojsonPeaks();
      if (response == null) {
        throw Exception('Null response');
      }
      return response;
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }

  Future<Set<Waterfall>> getWaterfalls() async {
    try {
      final String? response = await _waterfallProvider.fetchWaterfall();
      if (response == null) {
        throw Exception('Null response');
      }

      final List features = jsonDecode(response)['features'] as List;
      final List<Map> data = features.map((e) => e as Map).toList();
      return data
          .map((e) => Waterfall.fromJson(e as Map<String, dynamic>))
          .toSet();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getWaterfallJson() async {
    try {
      String? response = await _waterfallProvider.fetchWaterfall();
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
