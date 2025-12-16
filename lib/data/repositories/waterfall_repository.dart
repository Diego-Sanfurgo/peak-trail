import 'dart:convert';
import 'dart:developer';

import 'package:peak_trail/data/models/waterfall.dart';
import 'package:peak_trail/data/providers/waterfall_provider.dart';

class WaterfallRepository {
  WaterfallRepository(this._provider);
  final WaterfallProvider _provider;

  Future<Set<Waterfall>> getWaterfalls() async {
    try {
      final String? response = await _provider.fetchWaterfall();
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
      String? response = await _provider.fetchWaterfall();
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
