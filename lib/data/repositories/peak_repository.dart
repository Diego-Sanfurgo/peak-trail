import 'dart:developer';

import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/providers/peak_provider.dart';

class PeakRepository {
  PeakRepository(this._provider);

  final PeakProvider _provider;

  Future<Set<Peak>> getPeaks() async {
    try {
      return await _provider.fetchPeaks();
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<String> getPeaksJson() async {
    try {
      return await _provider.fetchPeaksJson();
    } on Exception catch (e) {
      log(e.toString());
      return '';
    }
  }
}
