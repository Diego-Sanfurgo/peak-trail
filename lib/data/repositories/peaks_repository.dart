import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/providers/peak_provider.dart';

class PeaksRepository {
  factory PeaksRepository() => _instance;
  PeaksRepository._internal();
  static final PeaksRepository _instance = PeaksRepository._internal();

  final PeakProvider _provider = PeakProvider();
  Set<Peak> mountains = {};

  Future<Set<Peak>> getPeaks() async {
    if (mountains.isNotEmpty) return mountains;

    mountains = await _provider.fetchPeaks() ?? {};
    return mountains;
  }

  Future<String> getPeaksJson() async {
    return await _provider.fetchGeojsonPeaks();
  }
}
