import 'package:peak_trail/data/models/mountain.dart';
import 'package:peak_trail/data/providers/peak_provider.dart';

class MountainsRepository {
  factory MountainsRepository() => _instance;
  MountainsRepository._internal();
  static final MountainsRepository _instance = MountainsRepository._internal();

  final PeakProvider _provider = PeakProvider();
  Set<Mountain> mountains = {};

  Future<Set<Mountain>> getPeaks() async {
    if (mountains.isNotEmpty) return mountains;

    mountains = await _provider.fetchPeaks() ?? {};
    return mountains;
  }

  Future<String> getGeoJsonMountains() async {
    return await _provider.fetchGeojsonPeaks();
  }
}
