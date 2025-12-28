import 'dart:developer';

import 'package:peak_trail/data/models/waterfall.dart';
import 'package:peak_trail/data/providers/waterfall_provider.dart';

class WaterfallRepository {
  WaterfallRepository(this._provider);
  final WaterfallProvider _provider;

  Future<Set<Waterfall>> getWaterfalls() async {
    try {
      return await _provider.fetchWaterfall();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getWaterfallJson() async {
    try {
      return await _provider.fetchWaterfallJson();
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }
}
