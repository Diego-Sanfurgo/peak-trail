import 'dart:developer';

import 'package:peak_trail/data/models/lake.dart';
import 'package:peak_trail/data/models/mountain_pass.dart';
import 'package:peak_trail/data/providers/lake_provider.dart';
import 'package:peak_trail/data/providers/peak_provider.dart';
import 'package:peak_trail/data/providers/waterfall_provider.dart';

import '../models/peak.dart';
import '../models/waterfall.dart';
import '../providers/pass_provider.dart';

class MapRepository {
  MapRepository(
    this._peakProvider,
    this._waterfallProvider,
    this._passProvider,
    this._lakeProvider,
  );

  final PeakProvider _peakProvider;
  final WaterfallProvider _waterfallProvider;
  final MountainPassProvider _passProvider;
  final LakeProvider _lakeProvider;

  Future<Set<Peak>> getPeaks() async {
    try {
      return await _peakProvider.fetchPeaks();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<dynamic> getPeaksJson({bool asString = false}) async {
    try {
      return await _peakProvider.fetchPeaksJson(asString: asString);
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }

  Future<Set<Waterfall>> getWaterfalls() async {
    try {
      return await _waterfallProvider.fetchWaterfall();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getWaterfallJson() async {
    try {
      return await _waterfallProvider.fetchWaterfallJson();
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }

  Future<Set<MountainPass>> getPasses() async {
    try {
      return await _passProvider.fetchPass();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getPassJson() async {
    try {
      return await _passProvider.fetchPassJson();
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }

  Future<Set<Lake>> getLakes() async {
    try {
      return await _lakeProvider.fetchLakes();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getLakesJson() async {
    try {
      return await _lakeProvider.fetchLakesJson();
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }
}
